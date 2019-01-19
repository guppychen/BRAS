*** Settings ***
Documentation     The EXA device MUST support configuring how to access upto four RADIUS servers for authentication
...    These servers must be prioritized unambigiously.
...    Shared secret - 16-128 characters including spaces
...    Port  - default to 1812, or 1645 for authorization and 1813, or 1646 for accounting
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=gpalanis
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_Server_port_setting
    [Documentation]    1	With the Radius server port set to 1645 provision the EXA client with the same server port and its IP addres shared Secret etc	configuration took place	
    ...    2	Provision a client with default parameters login to start authentication process	User authenticated user communication to the system is established	can use Wireshark to capture the traffic to verify
    [Tags]       @author=gpalanis     @TCID=AXOS_E72_PARENT-TC-1336
    [Setup]      AXOS_E72_PARENT-TC-1336 setup
    [Teardown]   AXOS_E72_PARENT-TC-1336 teardown
    log    STEP:1 With the Radius server port set to 1645 provision the EXA client with the same server port and its IP addres shared Secret etc configuration took place

    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}    port=${invalid_port}

    Configure aaa authentication-order    n1_session1    ${authentication}

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session2    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}
    Session build local    n1_localsession2    ${conn}

    # Verify the tcpdump packet for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    Get capture    n1_session2    n1_localsession    ${interface}    ${radius_server2}   ${RadiusFileName}

    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request

    log    STEP:2 Provision a client with default parameters login to start authentication process User authenticated user communication to the system is established can use Wireshark to capture the traffic to verify

    # Temp step as port does not work- Remove radius server
    Remove radius server    n1_session1

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap

    # Configure the radius server with port 1812 - default
    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}    port=${default_port}

    # Verify the tcpdump packet
    ${RadiusFileName1}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession2    ${interface}    ${radius_server2}    ${RadiusFileName1}

    Verify packet capture    n1_session2    ${RadiusFileName1}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName1}    ${radius_server2}    ${DEVICES.n1_session1.ip}    2=Access-Accept


*** Keywords ***
AXOS_E72_PARENT-TC-1336 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1336 setup

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


AXOS_E72_PARENT-TC-1336 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1336 teardown

    # Destroy the local session
    Session destroy local    n1_localsession
    Session destroy local    n1_localsession2

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
