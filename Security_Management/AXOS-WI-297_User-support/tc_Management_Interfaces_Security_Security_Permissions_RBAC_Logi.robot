*** Settings ***
Documentation     EXA device MUST support the administrative function of assigning one or more role profiles to user profile
Test Setup        AXOS_E72_PARENT-TC-2698 setup
Test Teardown     AXOS_E72_PARENT-TC-2698 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
tc_Management_Interfaces_Security_Security_Permissions_RBAC_Login
    [Documentation]    1 Assign Oper,networkadmin,admin,Securityadmin roles to the sysadmin user
    ...    2 Verify that the user is assigned all four roles
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2698    @EUT=E3-2    @priority=1
    Comment    EXA device MUST support the administrative function of assigning one or more role profiles to user profile
    cli    n1    configure
    cli    n1    aaa user sysadmin role networkadmin
    cli    n1    aaa user sysadmin role oper
    cli    n1    aaa user sysadmin role admin
    cli    n1    exit
    cli    n1    show running-config aaa user sysadmin       prompt=${eutpmt}
    Result Should Contain    role admin networkadmin oper

*** Keywords ***
AXOS_E72_PARENT-TC-2698 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2698 setup

AXOS_E72_PARENT-TC-2698 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2698 teardown
    Disconnect    n1
