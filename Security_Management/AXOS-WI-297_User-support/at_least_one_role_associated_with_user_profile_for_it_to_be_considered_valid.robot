*** Settings ***
Documentation     There must always be at least one role associated with a user profile for it to be considered valid.
Test Setup        AXOS_E72_PARENT-TC-2707 setup
Test Teardown     AXOS_E72_PARENT-TC-2707 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
at_least_one_role_associated_with_user_profile_for_it_to_be_considered_valid
    [Documentation]    1 Login as sysadmin
    ...    2 remove networkadmin role from networkadmin ,should not be able to remove
    ...    3 remove oper role from support,should not be able to remove
    ...    4 remove adminrole profiles from tac,should not be able to remove
    ...    5 Remove admin role profile from sysadmin,should not be able to remove
    [Tags]  @TCID=AXOS_E72_PARENT-TC-2707    @EUT=E3-2    @priority=1
    Comment    EXA device MUST support the administrative function of assigning one or more role profiles to user profile
    cli    n1    configure
    cli    n1    no aaa user tac role admin
    Result Should Contain    Aborted: too few 'aaa user tac role', 0 configured, at least 1 must be configured
    cli    n1    no aaa user networkadmin role networkadmin
    Result Should Contain    Aborted: too few 'aaa user networkadmin role', 0 configured, at least 1 must be configured
    cli    n1    no aaa user support role oper
    Result Should Contain    Aborted: too few 'aaa user support role', 0 configured, at least 1 must be configured
    cli    n1    no aaa user monitor role oper
    Result Should Contain    Aborted: too few 'aaa user monitor role', 0 configured, at least 1 must be configured

*** Keywords ***
AXOS_E72_PARENT-TC-2707 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2707 setup
    cli    n1    configure
    Delete User in the Device    n1    ${user1.name}
    cli    n1    configure
    Command    n1    aaa user tac role admin

AXOS_E72_PARENT-TC-2707 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2707 teardown
    Disconnect    n1
