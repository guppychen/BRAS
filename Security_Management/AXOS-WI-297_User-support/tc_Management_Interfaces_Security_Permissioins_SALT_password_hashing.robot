*** Settings ***
Documentation     EXA Device MUST store passwords using SALT password hashing
Test Setup        AXOS_E72_PARENT-TC-2679 setup
Test Teardown     AXOS_E72_PARENT-TC-2679 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Variables ***

*** Test Cases ***
tc_Management_Interfaces_Security_Permissioins_SALT_password_hashing
    [Documentation]    1 Login as sysadmin create user(User1) and assign role/password login successful user created
    ...    2 verify role shown with associated user shows role for user
    ...    3 verify password is shown as SALT hashed password stored using SALT password hasing
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2679    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
    ${check}    cli    n1    show running-config aaa user ${user1.name}   prompt=${eutpmt}
    Log    Step2:show default TAC user and role profile is supported defualt TAC
    Should Contain    ${check}    ${user1.name}
    Should not Contain    ${check}    ${user1.password}
    Disconnect    n1

*** Keywords ***
AXOS_E72_PARENT-TC-2679 setup
    log    Enter AXOS_E72_PARENT-TC-2679 setup

AXOS_E72_PARENT-TC-2679 teardown
    log    Enter AXOS_E72_PARENT-TC-2679 teardown
    Delete User in the Device    n1    ${user1.name}
