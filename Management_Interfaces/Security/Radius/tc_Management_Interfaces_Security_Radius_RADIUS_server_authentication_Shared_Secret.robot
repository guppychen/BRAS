*** Settings ***
Documentation     The EXA device MUST support configuring how to access upto four RADIUS servers for authentication
...    These servers must be prioritized unambigiously.
...    Shared secret - 16-128 characters including spaces
...    Port  - default to 1812, or 1645 for authorization and 1813, or 1646 for accounting
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=kshettar
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_RADIUS_server_authentication_Shared_Secret
    [Documentation]    1	provision 2 different Radius servers in the EXA device with correct server IP address port (default to 1812) and shared Secret	Configuration successful	use "show" to verify
    ...    2	provision the client with default settings and connect both authentication servers		
    ...    3	Loging to start authentication process. Monitor/capture the authentication traffic	Authentication succeeded with AS1 and access granted.	
    ...    4	through provisioning change the Shared Secret for server 1 at the client side to make it mismatch with AS1	Configuration successful	use "show" to verify
    ...    5	Log in to start authentication process. Monitor/capture the authentication traffic	Access-Request is sent to server 1, but with the incorrect Shared Secret. The Radius server rejects the request and or responds with Access-Reject. The card should then try authentication with AS2. If the user is present on AS2 - login is successful (if not AS2 replies with "Access Reject" too)	Make sure the card tries authentication with all the configured RADIUS servers (and finally Local) before declaring failure
    [Tags]       @author=kshettar     @TCID=AXOS_E72_PARENT-TC-1338
    [Setup]      AXOS_E72_PARENT-TC-1338 setup
    [Teardown]   AXOS_E72_PARENT-TC-1338 teardown

    Cli    n1_session1    show version
    log    STEP:1 provision 2 different Radius servers in the EXA device with correct server IP address port (default to 1812) and shared Secret Configuration successful use "show" to verify
    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}    priority=1
    Configure radius server    n1_session1    ${radius_server3}    secret=${secret}    priority=2

    log    STEP:2 provision the client with default settings and connect both authentication servers
    #Configure aaa authentication order
    Configure aaa authentication-order    n1_session1    ${authentication}

    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session2   user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}
    Session build local    n1_localsession1    ${conn}

    log    STEP:3 Loging to start authentication process. Monitor/capture the authentication traffic Authentication succeeded with AS1 and access granted.

    # tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession    ${interface}    ${radius_server2}   ${RadiusFileName}

    #Verify packet capture for access-request and accesss-accept
    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server2}    ${DEVICES.n1_session1.ip}     2=Access-Accept

    # Removing the pcap files
#    cli    n1_session2    rm -rf ${RadiusFileName}.pcap

    log    STEP:4 through provisioning change the Shared Secret for server 1 at the client side to make it mismatch with AS1 Configuration successful use "show" to verify
    Configure radius server    n1_session1    ${radius_server2}    secret=${invalid_secret}    priority=1

    log    STEP:5 Log in to start authentication process. Monitor/capture the authentication traffic Access-Request is sent to server 1, but with the incorrect Shared Secret. The Radius server rejects the request and or responds with Access-Reject. The card should then try authentication with AS2. If the user is present on AS2 - login is successful (if not AS2 replies with "Access Reject" too) Make sure the card tries authentication with all the configured RADIUS servers (and finally Local) before declaring failure

    # tcpdump for RADIUS messages
    ${server}    set variable    ${radius_server2} or ${radius_server3}
    ${RadiusFileName}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession1    ${interface}    ${server}   ${RadiusFileName}

    #Verify packet capture for access-request and accesss-reject on server1
    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server2}    ${DEVICES.n1_session1.ip}     3=Access-Reject

    #Verify packet capture for access-request and accesss-accept on server2
    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server3}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server3}    ${DEVICES.n1_session1.ip}     2=Access-Accept


*** Keywords ***
AXOS_E72_PARENT-TC-1338 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1338 setup

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Remove Radius user
    Remove aaa user    n1_session1    ${radius_admin_user}


AXOS_E72_PARENT-TC-1338 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1338 teardown

    # Destroy the local session
    Session destroy local    n1_localsession
    Session destroy local    n1_localsession1

    #Remove Authenitcation order
    Remove aaa authentication-order    n1_session1

    #Remove radius server
    Remove radius server    n1_session1
    Remove radius retry    n1_session1

    # Ctrl+C to break the tcpdump packet capture
    cli    n1_session2    \x03     \\~#

    # Removing the pcap files
#    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
