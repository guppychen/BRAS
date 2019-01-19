*** Settings ***
Documentation     These servers must be prioritized unambigiously.
...    ====================================================================
...    The purpose of this test is to verify RADIUS provisioning. User should be able to configure up to 4 servers and they should be used for authentication in the order they were configured. 
Force Tags        @feature=AAA    @subfeature=RADIUS client authentication server support    @author=rakrishn
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Management_Interfaces_Security_Radius_The_EXA_device_MUST_support_configuring_how_to_access_upto_four_RADIUS_servers_for_authentication
    [Documentation]    1	Provision Multiple (up to 4) Radius servers on the EXA device, Authentication Server 1 to 4; each with its unique server IP address, and a shared Secret name, and port (default to 1812)	system allows to provision up to 4 radius servers (example: as1, as2, as3, as4)	
    ...    2	show provisioned Radius servers	all provisioned server configurations are displayed	
    ...    3	Test Authentication 	If a valid user auth is used; it should succeed. Device should try all provisioned for authentication in an order user provisioned. 	
    ...    4	Delete Radius server(s)	able to delete any of the provisioned servers	
    ...    5	show Radius server(s), confirm the deletion	deleted server(s) no longer exist
    [Tags]       @author=rakrishn     @TCID=AXOS_E72_PARENT-TC-1327
    [Setup]      AXOS_E72_PARENT-TC-1327 setup
    [Teardown]   AXOS_E72_PARENT-TC-1327 teardown

    log    STEP:1 Provision Multiple (up to 4) Radius servers on the EXA device, Authentication Server 1 to 4; each with its unique server IP address, and a shared Secret name, and port (default to 1812) system allows to provision up to 4 radius servers (example: as1, as2, as3, as4)
    log    STEP:2 show provisioned Radius servers all provisioned server configurations are displayed

    Configure aaa authentication-order    n1_session1    ${authentication}

    :FOR    ${count}    IN RANGE     1    5
    \    Configure radius server    n1_session1    ${radius_server${count}}    secret=${secret}

    log    STEP:3 Test Authentication If a valid user auth is used; it should succeed. Device should try all provisioned for authentication in an order user provisioned.
    log    STEP:4 Delete Radius server(s) able to delete any of the provisioned servers
    log    STEP:5 show Radius server(s), confirm the deletion deleted server(s) no longer exist

    :FOR    ${count}    IN RANGE     1    5
    \    ${conn}=    Session copy info    n1_session2    user=${radius_admin_user}    password=${radius_admin_password}
    \    Session build local    n1_localsession    ${conn}
    \    ${RadiusFileName}    generate_pcap_name     radius
    \    Get packet capture    n1_session2    n1_localsession    ${interface}    ${radius_server${count}}   ${RadiusFileName}
    \    Verify packet capture    n1_session2    ${RadiusFileName}    ${DEVICES.n1_session1.ip}     ${radius_server${count}}    1=Access-Request
    \    Verify packet capture    n1_session2    ${RadiusFileName}    ${radius_server${count}}    ${DEVICES.n1_session1.ip}     2=Access-Accept
#    \    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    \    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap
    \    Session destroy local    n1_localsession
    \    cli    n1_session1    conf
    \    cli    n1_session1    no aaa radius server ${radius_server${count}}    \\#    30
    \    cli    n1_session1    end
    \    cli    n1_session1    show running-config aaa radius server | nomore    \\#    30
    \    Result should not contain    ${radius_server${count}}
    \    Configure radius server    n1_session1    ${radius_server${count}}    secret=${secret}
#    \    cli    n1_session2    rm -rf /tmp/${RadiusFileName}.pcap
#    \    cli    n1_session2    rm -rf /tmp/${RadiusFileName1}.pcap


*** Keywords ***
AXOS_E72_PARENT-TC-1327 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1327 setup
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


AXOS_E72_PARENT-TC-1327 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1327 teardown

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
