*** Settings ***
Documentation     The EXA device MUST support configuration of how to use a RADIUS server that includes host, port, shared secret, timeout, retries, shared secret
...    The configuration to access a RADIUS server includes:
...        host  - IPAddress of fully qualified domain name
...        mode - accounting or authorization (informative as ports are mode specific)
...        port  - default to 1812, or 1645 for authorization and 1813, or 1646 for accounting
...        shared secret - 16-128 characters including spaces
...        timeout - seconds to wait before timeing out a request to the RADIUS server [1..30 secs default 3]
...        retries -  number of consecutive retries to attempt. If all time out, then the RADIUS server is marked as unreachable [1..10 default 3]
...        priority relative to other configurated access to RADIUS servers.
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=dzala
Resource          ./base.robot


*** Variables ***
@{output}    []

*** Test Cases ***
tc_Management_Interfaces_Security_Radius_configuration_for_request_message_Retries_to_the_Radius_server
    [Documentation]    1	Configure RADIUS sever on the EXA device. Include all the required parameters (Server IP/Name, Secret, retries, timeout etc.)	Show config to verify that the configuration was successful	You may or may not use default parameters
    ...    2	Try to login as one of the user on the RADIUS server. 	Login should be successful	
    ...    3	Change the RADIUS configuration: (a) Add Invalid RADIUS server name and/or ip		
    ...    4	Change the RADIUS configuration: (b) Change retries value to something other than the default value (say x)		
    ...    5	Show configuration	Verify that changes to RADIUS configuration were successful	
    ...    6	Start Wireshark capture		
    ...    7	Try to login to the card with valid credentials	Login request should be rejected	
    ...    8	Complete the Wireshark capture	Make sure that authentication packets are sent 'x' number of times before the request fails	
    ...    9	Try setting retry value to 0 (or less)	Request denied	
    ...    10	Try setting retry value to anything more than 10	Request denied
    [Tags]       @author=dzala     @TCID=AXOS_E72_PARENT-TC-1341
    [Setup]      AXOS_E72_PARENT-TC-1341 setup
    [Teardown]   AXOS_E72_PARENT-TC-1341 teardown
    log    STEP:1 Configure RADIUS sever on the EXA device. Include all the required parameters (Server IP/Name, Secret, retries, timeout etc.) Show config to verify that the configuration was successful You may or may not use default parameters

    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}

    Configure aaa authentication-order    n1_session1    ${authentication}

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session2    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}
    Session build local    n1_localsession1    ${conn}

    log    STEP:2 Try to login as one of the user on the RADIUS server. Login should be successful
    # Verify the tcpdump packet
    ${RadiusFileName}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession    ${interface}    ${radius_server2}    ${RadiusFileName}

    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server2}    ${DEVICES.n1_session1.ip}    2=Access-Accept


    log    STEP:3 Change the RADIUS configuration: (a) Add Invalid RADIUS server name and/or ip
    log    STEP:4 Change the RADIUS configuration: (b) Change retries value to something other than the default value (say x)
    log    STEP:5 Show configuration Verify that changes to RADIUS configuration were successful

    Remove radius server    n1_session1
    Configure radius server    n1_session1    ${invalid_server}    secret=${secret}
    Configure radius retry    n1_session1    ${radius_retry1}

    log    STEP:6 Start Wireshark capture
    log    STEP:7 Try to login to the card with valid credentials Login request should be rejected
    log    STEP:8 Complete the Wireshark capture Make sure that authentication packets are sent 'x' number of times before the request fails


    # Retrieve retry and timeout count value
    ${res}    Cli    n1_session1    show running-config aaa radius retry | details
    @{retry}    should match regexp    ${res}    aaa radius retry ([\\d]+)
    ${retry_num}    Set variable    @{retry}[1]
    ${res}    Cli    n1_session1    show running-config aaa radius server ${invalid_server} timeout | details
    @{timeout}   should match regexp    ${res}   aaa radius server ${invalid_server} timeout ([\\d]+)

    ${RadiusFileName1}    generate_pcap_name     radius
    Get capture    n1_session2    n1_localsession1    ${interface}    ${invalid_server}   ${RadiusFileName1}

    ${res}    cli    n1_session2
    ...    tcpdump -nnvXSs 0 -A -r ${RadiusFileName1}.pcap "src host ${DEVICES.n1_session1.ip}" and "dst host ${invalid_server}" and "udp[8] == 1" | grep -ir ".* IP"
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

    log    STEP:9 Try setting retry value to 0 (or less) Request denied
    log    STEP:10 Try setting retry value to anything more than 10 Request denied

    cli    n1_session1    conf
    cli    n1_session1    aaa radius retry 0
    Result Match Regexp    syntax error:.*is out of range
    cli    n1_session1    aaa radius retry ${invalid_range_retry}
    Result Match Regexp    syntax error:.*is out of range


*** Keywords ***
AXOS_E72_PARENT-TC-1341 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1341 setup

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap

    # Remove Radius user
    Remove aaa user    n1_session1    ${radius_admin_user}


AXOS_E72_PARENT-TC-1341 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1341 teardown
    # Destroy the local session
    Session destroy local    n1_localsession
    Session destroy local    n1_localsession1

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

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
