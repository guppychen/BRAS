*** Settings ***
Documentation    
Resource          ./base.robot


*** Variables ***
@{output}    []
@{output1}    []


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Number_of_authentication_retry_attempts_to_the_Radius_server
    [Documentation]
      
    ...    1	Configure a Radius server with default server information but with an incorrect IP address.	Configuration successful. Show to verify		
    ...    2	Provision a client with default parameters monitor/capture the authentication traffic via Wireshark. Try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds. After retry for 3 times it should timeout.		
    ...    3	Through provisioning change the number of Retries to 10 try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds. After retry for 10 times it should timeout.		

    
    [Tags]     @author=YUE SUN     @tcid=AXOS_E72_PARENT-TC-1332      @globalid=2319914      @priority=P1    @eut=10GE-12          @user_interface=CLI	
    [Setup]      case_setup
    [Teardown]   case_teardown
    log    STEP:1 Configure a Radius server with default server information but with an incorrect IP address. Configuration successful. Show to verify
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}
    prov_aaa_authentication_order    euta_radius    ${authentication}

    log    STEP:2 Provision a client with default parameters monitor/capture the authentication traffic via Wireshark. Try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. After retry for 3 times it should timeout.
    prov_radius_retry    euta_radius    ${radius_retry}

    # Retrieve retry and timeout count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+) 

    ${RadiusFileName}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession    ${interface_craft}    ${invalid_server}   ${RadiusFileName}

    ${res}    cli    eutB_root
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName} "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    run keyword if   ${arg.__contains__('IP')}==True    Append To List    ${output}    @{var}[0]
    Remove From List    ${output}    0
    ${length}    Get Length    ${output}
    ${length1}    Evaluate    (${length}-3)/3

    # Check if number of retry is same as what is configured
    Should be true    ${length1} == ${radius_retry}

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

    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"

    log    STEP:3 Through provisioning change the number of Retries to 10 try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. After retry for 10 times it should timeout.

    # dprov_radius_server    euta_radius
    # prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}
    prov_radius_retry    euta_radius    ${radius_retry1}

    # Retrieve retry and timeout count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+) 

    ${RadiusFileName1}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession    ${interface_craft}    ${invalid_server}   ${RadiusFileName1}

    ${res}    cli    eutB_root
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1} "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    run keyword if   ${arg.__contains__('IP')}==True        Append To List    ${output1}    @{var}[0]
    Remove From List    ${output1}    0
    ${length}    Get Length    ${output1}
    ${length1}    Evaluate    (${length}-3)/3

    # Check if number of retry is same as what is configured
    Should be true    ${length1} == ${radius_retry1}

    # Check if retries are sent for timeout value set
    ${length}    Evaluate    ${length}-2
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output1}[${ini_index}]    @{output1}[${index}]
    \    ${res}    Subtract Time From Time    @{output1}[${ini_index}]    @{output1}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == @{timeout}[1]
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1

    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName1}"
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_radius_server    euta_radius    ${radius_server} 
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    euta_localsession    ${conn}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    euta_localsession2
    Session destroy local    euta_localsession
    dprov_radius_server    euta_radius    ${invalid_server} 
    dprov_radius_retry    euta_radius    ${radius_retry1}
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"
    
