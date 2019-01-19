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
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=sdas
Resource          ./base.robot


*** Variables ***
@{output}    []
@{output1}    []


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Authentication_request_timeout_to_the_Radius_server
    [Documentation]    1	Configure the Radius server information, but with an incorrect IP address, so no response from the server		
    ...    2	Provision a client session with default parameters, monitor/capture the authentication traffic via Wireshark (default timout = 3s), try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds.	would stop when it reaches the no. of retries set
    ...    3	through provisioning, change the timeout to 30s, try to login to start authentication process	Access-Request should be sent out from the EXA client every 30 seconds.	if Access-Challenge is also implemented (not in the SR), need to add more steps.
    [Tags]       @author=sdas     @TCID=AXOS_E72_PARENT-TC-1331
    [Setup]      AXOS_E72_PARENT-TC-1331 setup
    [Teardown]   AXOS_E72_PARENT-TC-1331 teardown
    log    STEP:1 Configure the Radius server information, but with an incorrect IP address, so no response from the server
    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}

    Configure aaa authentication-order    n1_session1    ${authentication}

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session1    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}

    # Retrieve retry count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

    log    STEP:2 Provision a client session with default parameters, monitor/capture the authentication traffic via Wireshark (default timout = 3s), try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. would stop when it reaches the no. of retries set
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
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == ${default_timeout}
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1

    log    STEP:3 through provisioning, change the timeout to 30s, try to login to start authentication process Access-Request should be sent out from the EXA client every 30 seconds. if Access-Challenge is also implemented (not in the SR), need to add more steps.

    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}    timeout=${radius_timeout}

    # Retrieve retry count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]

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
    \    continue for loop if   ${temp} < 0
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == ${radius_timeout}
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1

*** Keywords ***
AXOS_E72_PARENT-TC-1331 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1331 setup

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


AXOS_E72_PARENT-TC-1331 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1331 teardown
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
