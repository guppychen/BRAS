*** Settings ***
Documentation     The EXA device must support consistent authentication of users via each management interface using RADIUS. The management interfaces include:
...    
...        EWI
...        NetConf
...        CLI
...    
...    ================================================================================================================
...    
...    The purpose of this test is to verify that RADIUS Authentication works via management interfaces specified above. 
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=bswamina
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_security_Radius_EXA_Device_must_support_RADIUS_based_authentications_of_users_via_all_management_interfaces_CLI
    [Documentation]    1	configure the system with Radius server and client session (with server IP and shared Secret), and connect to the Radius server network 	all parameters are set to default value	
    ...    2	Login from the CLI session. monitor traffic with Wireshark or verify the authenticated client at the Radius server	Session is authenticated, and connection to the system is established/access granted. 
    [Tags]       @author=bswamina     @TCID=AXOS_E72_PARENT-TC-1326
    [Setup]      AXOS_E72_PARENT-TC-1326 setup
    [Teardown]   AXOS_E72_PARENT-TC-1326 teardown
    log    STEP:1 configure the system with Radius server and client session (with server IP and shared Secret), and connect to the Radius server network all parameters are set to default value
    Configure radius server    n1_session1    ${radius_server2}    secret=${secret}

    Configure aaa authentication-order    n1_session1    ${authentication}

    log    STEP:2 Login from the CLI session. monitor traffic with Wireshark or verify the authenticated client at the Radius server Session is authenticated, and connection to the system is established/access granted.
    # Creating local session for radius user
    ${conn}=    Session copy info    n1_session2    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession    ${conn}

    # tcpdump for RADIUS messages
    ${RadiusFileName}    generate_pcap_name     radius
    Get packet capture    n1_session2    n1_localsession    ${interface}    ${radius_server2}   ${RadiusFileName}

    #Verify packet capture for access-request and accesss-accept
    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server2}    1=Access-Request
    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server2}    ${DEVICES.n1_session1.ip}     2=Access-Accept

    # Check if radius server was successfully logged in
    cli    n1_session1    show user-sessions session session-login
    Result should contain    ${radius_admin_user}


*** Keywords ***
AXOS_E72_PARENT-TC-1326 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1326 setup

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


AXOS_E72_PARENT-TC-1326 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1326 teardown

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
