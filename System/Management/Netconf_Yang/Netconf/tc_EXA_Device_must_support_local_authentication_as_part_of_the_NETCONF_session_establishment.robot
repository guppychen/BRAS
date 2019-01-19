*** Settings ***
Documentation     If a local database of user authentication data is stored on the device, its inclusion in configuration data is an implementation-dependent matter. The actual passwords MUST not be part of the exported configuration data.
...               The user name used for login purposes maps to the role based access control mechanism described lated in this document. The permissions associated with the user's roles are expected to be enforced via the NETCONF server
Force Tags    @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao     @author=sdas
Resource          ./base.robot

*** Variables ***
${edit-config}    <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>changed_hostname</hostname></system></config></config>

${close-session}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <close-session/> </rpc>

${get_interface_details}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="2"> <get-config> <source> <running/> </source> <filter type="xpath" select="/*/interface[name='${DEVICES.n1_session1.ports.subscriber_p2.port}']"/> </get-config> </rpc>

${check_interface_name}    name

${get-hostname}    <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="4"><get-config><source><running/></source><filter type="xpath" select="/* /system/hostname"/></get-config></rpc>


*** Test Cases ***
tc_EXA_Device_must_support_local_authentication_as_part_of_the_NETCONF_session_establishment
    [Documentation]    1 Open netconf session with a local admin user:    #    Action    Expected Result    Notes
    ...    ssh < admin-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ...    2 Enter user password. Session successfully connects.
    ...    3 perform "get" rpc to show that it is allowed Succeeds
    ...    4 Perform "edit-config" rpc to show that it is allowed Succeeds
    ...    5 Verify effect of previous edit Change is present
    ...    6 close the session
    ...    7 Open netconf session with a local operator user:
    ...    ssh < oper-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ...    8 perform "get" rpc to show that it is allowed Succeeds
    ...    9 Perform "edit-config" rpc to show that it is allowed access is denied. Operator user shouldn't have edit priveledges.
    ...    10 Verify effect of previous edit edit-config had no effect.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-1792        @globalid=2322323
    [Setup]    AXOS_E72_PARENT-TC-1792 setup

    # Logged in automatically with Netconf Get command
    log   perform "get" rpc to show that it is allowed Succeeds
    ${output}    Raw netconf configure    n1_session3    ${get_interface_details}    ${check_interface_name}
    Should be equal    ${output[0].text}    ${DEVICES.n1_session1.ports.subscriber_p2.port}

    ${edit_config_back_host}=    set variable     <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${actual_hostname}</hostname></system></config></config>

    log    Perform "edit-config" rpc to show that it is allowed Succeeds
    ###edit-config
    Edit netconf configure    n1_session3    ${edit-config}    ok

    log    Verify effect of previous edit Change is present
    ###verification part
    @{hostname1}    Raw netconf configure    n1_session3    ${get-hostname}    hostname
    Element Text Should Match    @{hostname1}    changed_hostname

    ### Revert back to original host name
    Edit netconf configure    n1_session3    ${edit_config_back_host}    ok
    @{host_org}    Raw netconf configure    n1_session3    ${get-hostname}    hostname
    Element Text Should Match    @{host_org}    ${actual_hostname}

    log    close the session
    Raw netconf configure    n1_session3    ${close-session}    ok

    log    Open netconf session with a local operator user: ssh < oper-user >@< ip > -p 830 -s netconf. Requests password for < admin-user >
    ### Create a local session for oper user
    Configure aaa user    n1_session1    ${operator_usr}    ${operator_pwd}    oper
    ${conn}=    Session copy info    n1_session3    user=${operator_usr}    password=${operator_pwd}
    Session build local    n1_localsession    ${conn}

    log    perform "get" rpc to show that it is allowed Succeeds
    Raw netconf configure    n1_localsession    ${get_interface_details}    ${check_interface_name}

    log    Perform "edit-config" rpc to show that it is allowed access is denied. Operator user shouldn't have edit priveledges.
    ###edit-config
    ${step9}=    Netconf Edit Config    n1_localsession    ${edit-config}    target=running
    Should Contain    ${step9.xml}    access-denied

    log    Verify effect of previous edit edit-config had no effect.
    @{hostname2}    Raw netconf configure    n1_localsession    ${get-hostname}    hostname
    Element Text Should Match    @{hostname2}    ${actual_hostname}

    [Teardown]    AXOS_E72_PARENT-TC-1792 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1792 setup
    [Documentation]    AXOS_E72_PARENT-TC-1792 setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1792 setup

    #Destroy the local host
    session destroy local    n1_localsession

    # Get the actual hostname of the device
    ${actual_hostname}=    Get hostname    n1_session1    ${default_hostname}
    ${actual_hostname}=    Strip string     ${actual_hostname}
    Set Global Variable    ${actual_hostname}    ${actual_hostname}
    log    ${actual_hostname}
    #${edit_config_back_host}=    set variable     <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${actual_hostname}</hostname></system></config></config>
    #Edit netconf configure    n1_session3    ${edit_config_back_host}    ok

AXOS_E72_PARENT-TC-1792 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1792 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1792 teardown

    ${edit_config_back_host}=    set variable     <config><config xmlns="http://www.calix.com/ns/exa/base"><system><hostname>${actual_hostname}</hostname></system></config></config>
    Edit netconf configure    n1_session3    ${edit_config_back_host}    ok

    #Destroy the local host
    session destroy local    n1_localsession

    # Remove operator user
    Remove aaa user    n1_session1    ${operator_usr}
