*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
@{output}    []

*** Test Cases ***
tc_Management_Interfaces_Security_Radius_configuration_for_request_message_Retries_to_the_Radius_server
    [Documentation]
      
    ...    1	Configure RADIUS sever on the EXA device. Include all the required parameters (Server IP/Name, Secret, retries, timeout etc.)	Show config to verify that the configuration was successful	You may or may not use default parameters	
    ...    2	Try to login as one of the user on the RADIUS server.	Login should be successful		
    ...    3	Change the RADIUS configuration: (a) Add Invalid RADIUS server name and/or ip			
    ...    4	Change the RADIUS configuration: (b) Change retries value to something other than the default value (say x)			
    ...    5	Show configuration	Verify that changes to RADIUS configuration were successful		
    ...    6	Start Wireshark capture			
    ...    7	Try to login to the card with valid credentials	Login request should be rejected		
    ...    8	Complete the Wireshark capture	Make sure that authentication packets are sent 'x' number of times before the request fails		
    ...    9	Try setting retry value to 0 (or less)	Request denied		
    ...    10	Try setting retry value to anything more than 10	Request denied		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1341      @globalid=2319923      @priority=P2      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 Configure RADIUS sever on the EXA device. Include all the required parameters (Server IP/Name, Secret, retries, timeout etc.) Show config to verify that the configuration was successful You may or may not use default parameters 
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}

    prov_aaa_authentication_order    euta_radius    ${authentication}

    log    Creating local session for radius user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}
    Session build local    euta_localsession1    ${conn}
    
    log    STEP:2 Try to login as one of the user on the RADIUS server. Login should be successful 
    log    Verify the tcpdump packet
    ${RadiusFileName}    generate_pcap_name     radius
    get_packet_capture    eutB_root    euta_localsession    ${interface_craft}    ${radius_server}    ${RadiusFileName}

    analyze_packet_capture    eutB_root    ${RadiusFileName}    ${DEVICES.euta_radius.ip}     ${radius_server}    1=Access-Request
    analyze_packet_capture    eutB_root    ${RadiusFileName}    ${radius_server}    ${DEVICES.euta_radius.ip}    2=Access-Accept

    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"
    
    log    STEP:3 Change the RADIUS configuration: (a) Add Invalid RADIUS server name and/or ip 
    log    STEP:4 Change the RADIUS configuration: (b) Change retries value to something other than the default value (say x) 
    log    STEP:5 Show configuration Verify that changes to RADIUS configuration were successful 
    dprov_radius_server    euta_radius    ${radius_server}
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}
    prov_radius_retry    euta_radius    ${radius_retry1}

    log    STEP:6 Start Wireshark capture 
    log    STEP:7 Try to login to the card with valid credentials Login request should be rejected 
    log    STEP:8 Complete the Wireshark capture Make sure that authentication packets are sent 'x' number of times before the request fails 
    
    log    Retrieve retry and timeout count value
    ${res}    Cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    Cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+)

    ${RadiusFileName1}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession1    ${interface_craft}    ${invalid_server}   ${RadiusFileName1}

    ${res}    cli    eutB_root
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1} "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output}    @{var}[0]
    Remove From List    ${output}    0
    ${length}    Get Length    ${output}
    ${length1}    Evaluate    (${length}-3)/3

    # Check if number of retry is same as what is configured
    Should be true    ${length1} == ${radius_retry1}

    # Check if retries are sent for timeout value set
    ${length}    Evaluate    ${length}-2
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output}[${ini_index}]    @{output}[${index}]
    \    ${res}    Subtract Time From Time    @{output}[${ini_index}]    @{output}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == @{timeout}[1]
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1
        
    log    STEP:9 Try setting retry value to 0 (or less) Request denied 
    log    STEP:10 Try setting retry value to anything more than 10 Request denied 
    cli    euta_radius    configure
    cli    euta_radius    aaa radius retry 0
    Result Match Regexp    syntax error:.*is out of range
    cli    euta_radius    aaa radius retry ${invalid_range_retry}
    Result Match Regexp    syntax error:.*is out of range
    
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName1}"

*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    Remove Radius user
    dprov_aaa_user    euta_radius    ${radius_admin_user}

case_teardown
    [Documentation]
    [Arguments]
    log    caseteardown
    log    Destroy the local session
    Session destroy local    euta_localsession
    Session destroy local    euta_localsession1
    dprov_radius_retry    euta_radius    ${radius_retry1}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"
