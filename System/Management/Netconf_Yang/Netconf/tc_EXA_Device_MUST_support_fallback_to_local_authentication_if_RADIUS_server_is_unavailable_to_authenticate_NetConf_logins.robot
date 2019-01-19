*** Settings ***
Documentation     EXA Device MUST support fallback to local authentication if RADIUS server is unavailable to authenticate NetConf logins
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=dzala
Resource          ./base.robot

*** Variables ***
${config-radius}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><aaa><authentication-order>${authentication}</authentication-order><radius><retry>5</retry><server><host>${radius_server1}</host><secret>${secret}</secret><priority>2</priority></server></radius></aaa></system></config></config>
${get-radius}     <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get-config><source><running/></source><filter type="xpath" select="/* /system/aaa"/></get-config></rpc>
${get-configserver}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get-config><source><running/></source><filter type="xpath" select="/* /system/aaa"/></get-config></rpc>
${close_session}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><close-session/></rpc>

*** Test Cases ***
tc_EXA_Device_MUST_support_fallback_to_local_authentication_if_RADIUS_server_is_unavailable_to_authenticate_NetConf_logins
    [Documentation]    1 Configure device for RADIUS Authentication
    ...    2 Open netconf session with a RADIUS user: ssh < user >@< ip > -p 830 -s netconf. + provide password
    ...    3 Open netconf session with a user with the same name and password for RADIUS and Local authentication: ssh < user >@< ip > -p 830 -s netconf.
    ...    4 Open netconf session with a local user that is not set up on RADIUS.
    [Tags]      @user=root   @TCID=AXOS_E72_PARENT-TC-1794        @globalid=2322325
 
    log    STEP:1 Configure device for RADIUS Authentication
    ${radius_config}=    Edit netconf configure    n1_session3    ${config-radius}    ok
    @{get_radius_config}=    Raw netconf configure    n1_session3    ${get-configserver}    host

    log    STEP:2 Open netconf session with a RADIUS user: ssh < user >@< ip > -p 830 -s netconf. + provide password
    ${conn}=    Session copy info    n1_session3    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession1    ${conn}

    #Packet capture on radius server
    cli    n1_session2    cd
    Get packet capture    n1_session2    n1_session1    ${interface}    ${radius_server1}    ${RadiusFileName}

    #Verification of captured packets
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    1=Access-Request
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    2=Access-Accept

    log    STEP:3 Open netconf session with a user with the same name and password for RADIUS and Local authentication: ssh < user >@< ip > -p 830 -s netconf.
    # Configure the RADIUS user locally on the box
    Configure aaa user    n1_session1    ${user1}    ${password1}    ${role}
    ${conn1}=    Session copy info    n1_session3    user=${user1}    password=${password1}
    Session build local    n1_session1_localsession2    ${conn1}

    #Packet capture
    Get packet capture    n1_session2    n1_session1    ${interface}    ${radius_server1}    ${RadiusFileName1}

    #Verification of packets
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    1=Access-Request
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    2=Access-Accept

    log    STEP:4 Open netconf session with a local user that is not set up on RADIUS.
    ${conn2}=    Session copy info    n1_session3
    Session build local    n1_localsession3    ${conn2}

    #Packet capture on local server
    Get packet capture    n1_session2    n1_session1    ${interface}    ${radius_server1}    ${RadiusFileName2}

    #Verification of packet on local server
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    1=Access-Request
    Verify packet capture    n1_session2    ${radius_server1}    ${DEVICES.n1_session1.ip}    3=Access-Reject

    [Teardown]    AXOS_E72_PARENT-TC-1794 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1794 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1794 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1794 teardown

    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3

    # Remove the authenticataion-order
    Remove aaa authentication-order    n1_session1

    # Remove radius server
    Remove Radius server    n1_session1

    # Remove aaa user
    Remove aaa user    n1_session1    ${user1}
