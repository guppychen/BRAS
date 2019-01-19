*** Settings ***
Documentation     The EXA device MUST support configuration of how to use a RADIUS server that includes host, port, shared secret, timeout, retries, shared secret
...    
...    The configuration to access a RADIUS server includes:
...    
...        host  - IPAddress of fully qualified domain name
...        mode - accounting or authorization (informative as ports are mode specific)
...        port  - default to 1812, or 1645 for authorization and 1813, or 1646 for accounting
...        shared secret - 16-128 characters including spaces
...        timeout - seconds to wait before timeing out a request to the RADIUS server [1..30 secs default 3]
...        retries -  number of consecutive retries to attempt. If all time out, then the RADIUS server is marked as unreachable [1..10 default 3]
...        priority relative to other configurated access to RADIUS servers.
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=ysnigdha
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
    [Tags]       @author=ysnigdha     @TCID=AXOS_E72_PARENT-TC-1340
    [Setup]      AXOS_E72_PARENT-TC-1340 setup
    [Teardown]   AXOS_E72_PARENT-TC-1340 teardown
    log    STEP:1 configure the EXA device as client to access the Radius server, with server IP, and other parameters with default settings, show configuration Request timeout to wait for the RADIUS server is default to 3 seconds

    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}
    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout ${default_timeout}

    Configure aaa authentication-order    n1_session1    ${authentication}

    # Retrieve retry count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session1    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}


    log    STEP:2 with the Radius server disconnected, change the Timeout to 1 sec, show configuration Timeout = 1 sec
    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}    timeout=1
    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout 1

    log    STEP:3 Log in to start the authentication process, and use Wireshark to monitor/capture the traffic EXA device is sending Access-Request to the server every second (till the reties reached)

    ${RadiusFileName}    generate_pcap_name     radius
    Get capture    n1_session2    n1_localsession    ${interface}    ${invalid_server}   ${RadiusFileName}

    ${res}    cli    n1_session2
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName}.pcap "src host ${DEVICES.n1_session1.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output}    @{var}[0]
    Remove From List    ${output}    0
    ${length}    Get Length    ${output}
    ${length}    Evaluate    ${length}-1
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

    log    STEP:4 with the Radius server disconnected, change the Timeout to the maximum 30 sec, show configuration Timeout = 30 sec

    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}    timeout=${radius_timeout}

    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    Result Should Contain    timeout ${radius_timeout}

    # Retrieve retry count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    log    STEP:5 Log in to start the authentication process, and use Wireshark to monitor/capture the traffic EXA device is sending Access-Request to the server every 30 seconds (till the reties reached)

    ${RadiusFileName1}    generate_pcap_name     radius
    Get capture    n1_session2    n1_localsession    ${interface}    ${invalid_server}   ${RadiusFileName1}

    ${res}    cli    n1_session2
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1}.pcap "src host ${DEVICES.n1_session1.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"

    @{res}    Split To Lines    ${res}    2
    :FOR    ${arg}    IN    @{res}
    \    @{var}    Split String    ${arg}
    \    log    @{var}[0]
    \    Append To List    ${output1}    @{var}[0]
    Remove From List    ${output1}    0
    ${length}    Get Length    ${output1}
    ${length}    Evaluate    ${length}-1
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
    Cli    n1_session1    conf
    cli    n1_session1    aaa radius server ${invalid_server} timeout ${invalid_range_timeout}
    Result Match Regexp    syntax error:.*is out of range
    cli    n1_session1    aaa radius server ${invalid_server} timeout ${invalid_range1_timeout}
    Result Match Regexp    syntax error:.*is out of range
    cli    n1_session1    end


*** Keywords ***
AXOS_E72_PARENT-TC-1340 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1340 setup
    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Remove Radius user
    Remove aaa user    n1_session1    ${radius_admin_user}


AXOS_E72_PARENT-TC-1340 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1340 teardown

    # Destroy the local session
    Session destroy local    n1_localsession

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Ctrl+C to break the tcpdump packet capture
    cli    n1_session2    \x03     \\~#

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap

#Get capture
#    [Arguments]    ${session1}    ${session2}    ${int}    ${server}    ${file}
#    [Documentation]    Keyword for getting tcpdump from the server to the mentioned filename
#    ...    Example:
#    ...    Get tcpdump n2 n1 radiusdump 10.243.250.61
#    ...    session1 is the root user
#    ...    session2 is the configured radius user
#
#    # Start packet capture
#    cli    ${session1}    tcpdump -i ${int} -nnvXSs 0 host ${server} -w ${file}.pcap    timeout_exception=0
#
#    Run Keyword And Expect Error    SSHLoginException    cli    ${session2}    configure
#
#    sleep    10s
#
#    cli    ${session1}    \x03     \\~#
