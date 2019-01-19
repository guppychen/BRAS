*** Settings ***
Documentation     There must always exist at least one user with system administrator role in order to perform administrative functions on the device.
Test Setup        AXOS_E72_PARENT-TC-2684 setup
Test Teardown     AXOS_E72_PARENT-TC-2684 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
tc_EXA_device_MUST_always_have_at_least_one_user_with_the_System_Administator_role
    [Documentation]    1 login the device successfully login
    ...    2 create user1 with role sysadmin user and role created successfully
    ...    3 create user2 with role oper user and role created successfully
    ...    4 check user1 should be sysadmin this user role is sysadmin
    ...    5 check user2 should be oper this user role is sysadmin
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2684    @priority=1    @EUT=E3-2
    cli    n1    configure
    log    STEP:5 check user2 should be oper this user role is oper
    ${check1}=    cli    n1    aaa user ${user1.name} role ${user1.role}    timeout_exception=0
    Should Contain    ${check1}    ${user1.role}
    ${check2}=    cli    n1    aaa user ${user1.name} role \ ${user1.role}    timeout_exception=0
    Should Contain    ${check2}    ${user2.role}
    Disconnect    n1

*** Keywords ***
AXOS_E72_PARENT-TC-2684 setup
    [Documentation]    Will Setup the test case by creating Users required for test case.
    log    STEP:2 create user1 with role sysadmin user and role
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
    log    STEP:3 create user2 with role oper user and role
    Make User in the Device    n1    ${user2.name}    ${user2.password}    ${user2.role}

AXOS_E72_PARENT-TC-2684 teardown
    [Documentation]    Will Delete the users that were made in the Setup.
    log    Enter AXOS_E72_PARENT-TC-2684 teardown
    log    STEP:6 Delete user1 and user2.
    Delete User in the Device    n1    ${user1.name}
    Delete User in the Device    n1    ${user2.name}
