*** Settings ***
Documentation 
Resource          ./base.robot


*** Variables ***
@{output}    []
@{output1}    []


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_configuration_for_Request_message_Timout_to_the_Radius_server
    [Documentation]    1	configure the EXA device as client to access the Radius server, with server IP, and other parameters with default settings, show configuration	Request timeout to wait for the RADIUS server is default to 3 seconds	
    ...    2	with the Radius server disconnected, change the Timeout to 1 sec, show configuration	Timeout = 1 sec	
    ...    3	Log in to start the authentication process, and use Wireshark to monitor/capture the traffic	EXA device is sending Access-Request to the server every second (till the retries reached)	
    ...    4	with the Radius server disconnected, change the Timeout to the maximum 30 sec, show configuration	Timeout = 30 sec	
    ...    5	Log in to start the authentication process, and use Wireshark to monitor/capture the traffic	EXA device is sending Access-Request to the server every 30 seconds (till the retries reached)	
    ...    6	Try to change the Timeout to 0, 31 seconds	Both entries rejected, out of range.
    [Tags]     @author=YUE SUN      @tcid=AXOS_E72_PARENT-TC-1340      @globalid=2319922      @priority=P1      @eut=10GE-12          @user_interface=CLI
    [Setup]      case_setup
    [Teardown]   case_teardown
    log    STEP:1 configure the EXA device as client to access the Radius server, with server IP, and other parameters with default settings, show configuration Request timeout to wait for the RADIUS server is default to 3 seconds

    cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout ${default_timeout}

    prov_aaa_authentication_order    euta_radius    ${authentication}

    # Retrieve retry count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    log    STEP:2 with the Radius server disconnected, change the Timeout to 1 sec, show configuration Timeout = 1 sec
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}    timeout=1
    cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout 1

    log    STEP:3 Log in to start the authentication process, and use Wireshark to monitor/capture the traffic EXA device is sending Access-Request to the server every second (till the reties reached)

    ${RadiusFileName}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession    ${interface_craft}    ${invalid_server}   ${RadiusFileName}

    ${res}    cli    eutB_root    tcpdump -nnvXSs 0 -A -r ${RadiusFileName} "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output}    @{var}[0]
    Remove From List    ${output}    0
    ${length}    Get Length    ${output}
    ${length}    Evaluate    ${length}-2
    Log List    ${output}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output}[${ini_index}]    @{output}[${index}]
    \    ${res}    Subtract Time From Time    @{output}[${ini_index}]    @{output}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == 1
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1
    
    log    Removing the pcap files
	cli    eutB_root     rm -rf "${RadiusFileName}"

    log    STEP:4 with the Radius server disconnected, change the Timeout to the maximum 30 sec, show configuration Timeout = 30 sec

    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}    timeout=${radius_timeout}

    cli    euta_radius    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout ${radius_timeout}

    # Retrieve retry count value
    ${res}    cli    euta_radius    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    log    STEP:5 Log in to start the authentication process, and use Wireshark to monitor/capture the traffic EXA device is sending Access-Request to the server every 30 seconds (till the reties reached)

    ${RadiusFileName1}    generate_pcap_name     radius
    get_capture    eutB_root    euta_localsession    ${interface_craft}    ${invalid_server}   ${RadiusFileName1}

    ${res}    cli    eutB_root
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1}.pcap "src host ${DEVICES.euta_radius.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"

    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output1}    @{var}[0]
    Remove From List    ${output1}    0
    ${length}    Get Length    ${output1}
    ${length}    Evaluate    ${length}-2
    Log List    ${output1}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output1}[${ini_index}]    @{output1}[${index}]
    \    ${res}    Subtract Time From Time    @{output1}[${ini_index}]    @{output1}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == ${radius_timeout}
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1


    log    STEP:6 Try to change the Timeout to 0, 31 seconds Both entries rejected, out of range.
    cli    euta_radius    conf
    cli    euta_radius    aaa radius server ${invalid_server} timeout ${invalid_range_timeout}
    Result Match Regexp    syntax error:.*is out of range
    cli    euta_radius    aaa radius server ${invalid_server} timeout ${invalid_range1_timeout}
    Result Match Regexp    syntax error:.*is out of range
    cli    euta_radius    end
    
    log    Removing the pcap files
	cli    eutB_root     rm -rf "${RadiusFileName1}"

*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    dprov_radius_server    euta_radius    ${radius_server} 
    prov_radius_server    euta_radius    ${invalid_server}    secret=${secret}
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
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    dprov_aaa_authentication_order    euta_radius    ${authentication}
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName}"
    Run Keyword And Ignore Error    cli    eutB_root    rm -rf "${RadiusFileName1}"
    