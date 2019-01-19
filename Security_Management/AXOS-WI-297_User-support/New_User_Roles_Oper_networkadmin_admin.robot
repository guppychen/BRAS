*** Settings ***
Documentation     New User - Roles Oper,networkadmin,admin
Test Setup        RLT-TC-13761 setup
Test Teardown     RLT-TC-13761 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
New_User_Roles_Oper_networkadmin_admin
    [Documentation]    1 Assign Oper,networkadmin,admin, roles to the new user
    ...    2 Verify that the user is assigned all four roles
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2699    @EUT=E3-2    @priority=1
    Comment    EXA device MUST support the administrative function of assigning one or more role profiles to user profile
    cli    n1    configure
    cli    n1    aaa user ${user1.name} role networkadmin
    cli    n1    aaa user ${user1.name} role oper
    cli    n1    aaa user ${user1.name} role admin
    cli    n1    exit
    cli    n1    show running-config aaa user ${user1.name}    prompt=${eutpmt}
    Result Should Contain    role admin networkadmin

*** Keywords ***
RLT-TC-13761 setup
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-13761 setup

RLT-TC-13761 teardown
    [Documentation]
    [Arguments]
    log    Enter RLT-TC-13761 teardown
    Delete User in the Device    n1    ${user1.name}
    Disconnect    n1
