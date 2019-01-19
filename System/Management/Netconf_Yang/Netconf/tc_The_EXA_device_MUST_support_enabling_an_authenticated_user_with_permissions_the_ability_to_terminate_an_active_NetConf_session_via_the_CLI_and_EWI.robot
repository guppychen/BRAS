*** Settings ***
Documentation     For an authenticated user with the appropriate permissions, the EXA device must enable the user to terminate an active netconf session. The termination of the netconf session results in behavior consistent with RFC 6241 wrt to session termination. Uncommitted confirmed-commit operations need to be rolled back and locks for the session need to be released.
...    
...    
...    Note: this action requires a log to be recorded to the audit/security log outlining for the user who initiated the termination the who(user id/session), what, when where, why. The record needs to record wrt "what" - which user's session was terminated and the consequences - locks, rollbacks and data stores affected.
Resource          ./base.robot
Force Tags        @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=pmunisam

*** Variables ***


*** Test Cases ***
tc_The_EXA_device_MUST_support_enabling_an_authenticated_user_with_permissions_the_ability_to_terminate_an_active_NetConf_session_via_the_CLI_and_EWI
    [Documentation]    EXA device MUST support enabling an authenticated user with permissions the ability to terminate an active Netconf session via the CLI and EWI    
    [Tags]       @author=pmunisam     @TCID=AXOS_E72_PARENT-TC-1771        @globalid=2322302
    [Setup]      AXOS_E72_PARENT-TC-1771 setup
    [Teardown]   AXOS_E72_PARENT-TC-1771 teardown
    
    # To create a active neconf session and retrieve the corresponding session id
    @{elem}    Get attributes netconf    n1_localsession1    //system/user-sessions     session-id
    ${count}   Get length   ${elem}
    ${localsession1_id}      set variable   ${elem[${count}-1].text}

    # To create a active neconf session and retrieve the corresponding session id
    @{elem}    Get attributes netconf    n1_localsession2    //system/user-sessions     session-id
    ${count}   Get length   ${elem}
    ${localsession2_id}      set variable   ${elem[${count}-1].text}

    # To verify whether a netconf session without locks can be killed by a active session
    cli    n1_localsession3    logout session ${localsession2_id}
    @{elem}    Get attributes netconf    n1_localsession1    //system/user-sessions     session-id
    ${count}   Get length   ${elem}
    List should not contain value   ${elem}   ${localsession2_id}
    
    # To verify whether a session with locks can be killed by a active session
    cli    n1_localsession3    logout session {localsession1_id}
    @{elem}    Get attributes netconf    n1_localsession1    //system/user-sessions     session-id
    ${count}   Get length   ${elem}
    List should not contain value   ${elem}   ${localsession1_id}


*** Keywords ***
AXOS_E72_PARENT-TC-1771 setup
    [Documentation]    AXOS_E72_PARENT-TC-1771 setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1771 setup

    # To bulid a netconf local session
    ${conn}=    Session copy info     n1_session3
    Session build local   n1_localsession1    ${conn}

    # To bulid a netconf local session
    ${conn}=    Session copy info     n1_session3
    Session build local   n1_localsession2    ${conn}
   
    # To bulid a cli local session
    ${conn}=    Session copy info     n1_session1
    Session build local   n1_localsession3    ${conn}
    

AXOS_E72_PARENT-TC-1771 teardown
    [Documentation]    AXOS_E72_PARENT-TC-1771 teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1771 teardown
    
    # To destroy the netconf and cli  local sessions
    Session destroy local    n1_localsession1
    Session destroy local    n1_localsession2
    Session destroy local    n1_localsession3
