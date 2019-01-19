*** Settings ***
Documentation     Tac User - Roles Oper,networkadmin,admin
Test Setup        AXOS_E72_PARENT-TC-2699 setup
Test Teardown     AXOS_E72_PARENT-TC-2699 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Tac_User_Roles_Oper_networkadmin_admin
    [Documentation]    1 Assign Oper,networkadmin,admin, roles to the tac user
    ...    2 Verify that the user is assigned all four roles
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2699    @EUT=E3-2    @priority=1
    Comment    EXA device MUST support the administrative function of assigning one or more role profiles to user profile
    cli    n1_session1    configure
    cli    n1_session1    aaa user tac role networkadmin
    cli    n1_session1    aaa user tac role oper
    cli    n1_session1    exit
    cli    n1_session1    show running-config aaa user tac   prompt=${eutpmt}
    Result Should Contain    role admin networkadmin oper
    disconnect    n1_session1

*** Keywords ***
AXOS_E72_PARENT-TC-2699 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2699 setup
    cli    n1    configure
    cli    n1    aaa user tac password admin role admin
AXOS_E72_PARENT-TC-2699 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2699 teardown
    cli    n1    configure
    cli    n1    no aaa user tac role networkadmin
    cli    n1    no aaa user tac role oper
