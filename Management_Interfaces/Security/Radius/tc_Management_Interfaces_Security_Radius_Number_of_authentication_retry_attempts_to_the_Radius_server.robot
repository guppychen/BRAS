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
Resource          ./base.robot
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=bswamina


*** Variables ***
@{output}    []
@{output1}    []


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Number_of_authentication_retry_attempts_to_the_Radius_server
    [Documentation]    1	Configure a Radius server with default server information but with an incorrect IP address.	Configuration successful. Show to verify	
    ...    2	Provision a client with default parameters monitor/capture the authentication traffic via Wireshark. Try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds. After retry for 3 times it should timeout.	
    ...    3	Through provisioning change the number of Retries to 10 try to login to start authentication process	Access-Request should be sent out from the EXA client every 3 seconds. After retry for 10 times it should timeout.
    [Tags]       @author=upandiri     @TCID=AXOS_E72_PARENT-TC-1332
    [Setup]      AXOS_E72_PARENT-TC-1332 setup
    [Teardown]   AXOS_E72_PARENT-TC-1332 teardown
    log    STEP:1 Configure a Radius server with default server information but with an incorrect IP address. Configuration successful. Show to verify
    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}

    Configure aaa authentication-order    n1_session1    ${authentication}

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session1    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}

    log    STEP:2 Provision a client with default parameters monitor/capture the authentication traffic via Wireshark. Try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. After retry for 3 times it should timeout.

    Configure radius retry    n1_session1    ${radius_retry}

    # Retrieve retry and timeout count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+) 

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
    ${length1}    Evaluate    (${length}-3)/3

    # Check if number of retry is same as what is configured
    Should be true    ${length1} == ${radius_retry}

    # Check if retries are sent for timeout value set
    ${length}    Evaluate    ${length}-1
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output}[${ini_index}]    @{output}[${index}]
    \    ${res}    Subtract Time From Time    @{output}[${ini_index}]    @{output}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == @{timeout}[1]
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1


    log    STEP:3 Through provisioning change the number of Retries to 10 try to login to start authentication process Access-Request should be sent out from the EXA client every 3 seconds. After retry for 10 times it should timeout.

    Remove radius server    n1_session1
    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}
    Configure radius retry    n1_session1    ${radius_retry1}

    # Retrieve retry and timeout count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+) 

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
    ${length1}    Evaluate    (${length}-3)/3

    # Check if number of retry is same as what is configured
    Should be true    ${length1} == ${radius_retry1}

    # Check if retries are sent for timeout value set
    ${length}    Evaluate    ${length}-1
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${ini_index}    Evaluate    ${index}+1
    \    log many    @{output1}[${ini_index}]    @{output1}[${index}]
    \    ${res}    Subtract Time From Time    @{output1}[${ini_index}]    @{output1}[${index}]    exclude_millis=True
    \    log many    ${retry_num}    ${index}
    \    ${temp}    Set variable    ${retry_num}
    \    Run Keyword If    ${retry_num} != ${index}    Should be true    ${res} == @{timeout}[1]
    \    ${retry_num}    Run Keyword If    ${retry_num} != ${index}    Set variable    ${temp}
    \    ...    ELSE    Evaluate    ${retry_num}+@{retry}[1]+1


*** Keywords ***
AXOS_E72_PARENT-TC-1332 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1332 setup

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


AXOS_E72_PARENT-TC-1332 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1332 teardown

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
#    cli    ${session1}    tcpdump -i ${int} -nnvXSs 0 host ${server} -w /tmp/${file}.pcap    timeout_exception=0
#
#    Run Keyword And Expect Error    SSHLoginException    cli    ${session2}    configure
#
#    sleep    10s
#
#    cli    ${session1}    \x03     \\~#
