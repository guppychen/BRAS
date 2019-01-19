*** Settings ***
Documentation     In order to support deployment scenarios with centralized authentication servers, a RADIUS client must be supported by the NETCONF authentication mechanism.
...
...               Also, verify that the Role of the RADIUS user is obeyed in NETCONF.
...
...
...               Note: This needs to be configurable to be enabled/disabled. One of either the local password store or the RADIUS server must be used for authentication.
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=upandiri
Resource          ./base.robot

*** Variables ***
${hostname}       E5_newname
${show-event-admin}    //status/system/event
${hostname1}      bogus
${get-hostname}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><get-config><source><running/></source><filter type="xpath" select="/* /system/hostname"/></get-config></rpc>

${get-configserver}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"><get-config><source><running/></source><filter type="xpath" select="/* /system/aaa"/></get-config></rpc>

${config-radius}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><aaa><authentication-order>${authentication}</authentication-order><radius><retry>5</retry><server><host>${radius_server1}</host><secret>${secret}</secret><priority>2</priority></server></radius></aaa></system></config></config>

${edit-config}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${hostname}</hostname></system></config></config>

${close-session}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="5"><close-session/></rpc>

${edit-config-oper}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${hostname1}</hostname></system></config></config>

${remove_authentication}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><aaa><authentication-order>local-only</authentication-order></aaa></system></config></config>

*** Test Cases ***
tc_EXA_Device_must_support_RADIUS_authentication_of_NETCONF_sessions
    [Documentation]    1 Open netconf session with a RADIUS admin user: ssh < admin-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >    #    Action    Expected Result    Notes
    ...    2 Enter user password. Session successfully connects.
    ...    3 perform "get" rpc to show that it is allowed Succeeds
    ...    4 Perform "edit-config" rpc to show that it is allowed Succeeds
    ...    5 Verify effect of previous edit Change is present
    ...    6 close the session
    ...    7 Open netconf session with a RADIUS operator user: ssh < oper-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ...    8 perform "get" rpc to show that it is allowed Succeeds
    ...    9 Perform "edit-config" rpc to show that it is allowed access is denied. Operator user shouldn't have edit priveledges.
    ...    10 Verify effect of previous edit edit-config had no effect.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1793        @globalid=2322324
    [Setup]    AXOS_E72_PARENT-TC-1793 setup

    log    Open netconf session with a RADIUS admin user: ssh < admin-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ${conn}=    Session copy info    n1_session3    user=${radius_admin_user}    password=${radius_admin_password}
    Session build local    n1_localsession1    ${conn}

    log    perform "get" rpc to show that it is allowed Succeeds
    @{events_admin}    Get attributes netconf    n1_localsession1    ${show-event-admin}    address
    ${count}    get length    ${events_admin}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    Run keyword if    '''${radius_server1}''' in '''${events_admin[${index}].text}'''    Exit for loop
    \    ...    ELSE    Continue FOR loop

    log    Perform "edit-config" rpc to show that it is allowed Succeeds
    ${var1}=    Edit netconf configure    n1_localsession1    ${edit-config}    ok

    # Verify effect of previous edit Change is present
    @{name}    Raw netconf configure    n1_localsession1    ${get-hostname}    hostname
    Element Text Should Match    @{name}    ${hostname}

    # close the session
    ${close_session}=    Raw netconf configure    n1_session3    ${close-session}    ok

    log    Open netconf session with a RADIUS operator user: ssh < oper-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ${conn}=    Session copy info    n1_session3    user=${user2}    password=${password2}
    Session build local    n1_localsession2    ${conn}

    # perform "get" rpc to show that it is allowed Succeeds
    @{events_admin}    Get attributes netconf    n1_localsession2    ${show-event-admin}    address
    ${count}    get length    ${events_admin}
    : FOR    ${index}    IN RANGE    0    ${count}
    \    Run keyword if    '''${radius_server1}''' in '''${events_admin[${index}].text}'''    Exit for loop
    \    ...    ELSE    Continue FOR loop

    #Perform "edit-config" rpc to show that it is allowed access is denied
    log    Perform "edit-config" rpc to show that it is allowed access is denied. Operator user shouldn't have edit priveledges.
    ${var3}=    Edit netconf configure    n1_localsession2    ${edit-config-oper}    error-tag

    #Verify effect of previous edit edit-config had no effect.
    @{name1}    Raw netconf configure    n1_localsession2    ${get-hostname}    hostname
    Should Not Contain    @{name1}    ${hostname1}
    [Teardown]    AXOS_E72_PARENT-TC-1793 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1793 setup
    [Documentation]    AXOS_E72_PARENT-TC-1793 setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1793 setup
    cli    n1_session1    clear active event-log

    #reverting hostname
    ${get_hostname}    Get hostname    n1_session1    ${default_hostname}
    ${get_hostname}    Strip string    ${get_hostname}
    Set Global Variable     ${edit-config_original}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${get_hostname}</hostname></system></config></config>
    ${var2}=    Edit netconf configure    n1_session3    ${edit-config_original}    ok
    ${radius_config}=    Edit netconf configure    n1_session3    ${config-radius}    ok
    @{get_radius_config}=    Raw netconf configure    n1_session3    ${get-configserver}    host

AXOS_E72_PARENT-TC-1793 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1793 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1793 teardown
   
    #Destroy the local host
    session destroy local    n1_localsession1
    session destroy local    n1_localsession2
    ${radius_config}=    Edit netconf configure    n1_session3    ${remove_authentication}    ok
    #reverting hostname
    ${var4}=    Edit netconf configure    n1_session3    ${edit-config_original}    ok
