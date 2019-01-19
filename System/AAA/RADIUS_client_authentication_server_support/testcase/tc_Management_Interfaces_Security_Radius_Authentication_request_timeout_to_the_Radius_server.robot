*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
@{output}    []
@{output1}    []

*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Authentication_request_timeout_to_the_Radius_server
    [Documentation]
      
    ...    1	Configure the Radius server information, but with an incorrect IP address, so no response from the server			
    ...    2	Provision a client session with default parameters, monitor/capture the authentication traffic via Wireshark (default timout = 3s), try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds.	would stop when it reaches the no. of retries set	
    ...    3	through provisioning, change the timeout to 30s, try to login to start authentication process	Access-Request should be sent out from the EXA client every 30 seconds.	if Access-Challenge is also implemented (not in the SR), need to add more steps.	

    
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-1331      @globalid=2319913      @priority=P1    @eut=10GE-12          @user_interface=cli    
    [Setup]      case_setup
    [Teardown]     case_teardown
      
    log    STEP:1 Configure the Radius server information, but with an incorrect IP address, so no response from the server 
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}    retry=${radius_retry}
    prov_aaa_authentication_order    euta_radius    ${authentication}
    
    log    Creating local session for radius user
    ${conn}=    Session copy info    euta_radius    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    radius_localsession    ${conn}
    
    log    Retrieve retry count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    
    log    STEP:2 Provision a client session with default parameters, monitor/capture the authentication traffic via Wireshark (default timout = 3s), try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. would stop when it reaches the no. of retries set 
    ${RadiusFileName}    generate_pcap_name     radius
    get_capture    eutB_root    radius_localsession    ${interface_craft}    ${invalid_server}    ${RadiusFileName}
    
    log    verify timeout equal to default timeout(default timout = 3s)
    ${res}    cli    eutB_root    tcpdump -nnvXSs 0 -A -r ${RadiusFileName} "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output}    @{var}[0]
    Log List    ${output}
    Remove From List    ${output}    0
    ${length}    Get Length    ${output}
    ${length}    Evaluate    ${length}-2
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output}[${ini_index}]    @{output}[${index}]
    \    ${res}    Subtract Time From Time    @{output}[${ini_index}]    @{output}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == ${default_timeout}
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1
    
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName}"
    
    log    STEP:3 through provisioning, change the timeout to 30s, try to login to start authentication process Access-Request should be sent out from the EXA client every 30 seconds. if Access-Challenge is also implemented (not in the SR), need to add more steps. 
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}    timeout=${radius_timeout}
    
    log    Retrieve retry count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    ${RadiusFileName1}    generate_pcap_name     radius
    get_capture    eutB_root    radius_localsession    ${interface_craft}    ${invalid_server}   ${RadiusFileName1}
    
    log    verify timeout equal to ${radius_timeout}
    ${res}    cli    eutB_root    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1}.pcap "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"    timeout=${radius_timeout}
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output1}    @{var}[0]
    Remove From List    ${output1}    0
    Log List    ${output1}
    ${length}    Get Length    ${output1}
    ${length}    Evaluate    ${length}-2
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output1}[${ini_index}]    @{output1}[${index}]
    \    ${res}    Subtract Time From Time    @{output1}[${ini_index}]    @{output1}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    continue for loop if   ${temp} < 0
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == ${radius_timeout}
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1
    
    log    Removing the pcap files
    cli    eutB_root    rm -rf "${RadiusFileName1}"

*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    Remove Radius user
    dprov_radius_server    euta_radius    ${radius_server}

case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    Destroy the local session
    Session destroy local    radius_localsession
    log    Remove radius server
    dprov_radius_server    euta_radius    ${invalid_server}
    prov_radius_server    euta_radius    ${radius_server}    secret=${secret}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"