*** Settings ***
Documentation     Never be able to retrieve a user password in its original form
Test Setup        AXOS_E72_PARENT-TC-2683 setup
Test Teardown     AXOS_E72_PARENT-TC-2683 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Never_be_able_to_retrieve_a_user_password_in_its_original_form
    [Documentation]    1 Login as sysadmin and create two user (user1/user2) as admin role
    ...    2 Login as user1 and update user2 role profile to include oper verify role profile
    ...    3 delete RBAC user profile and role profile
    ...    4 show system administrator user profile with admin role profile as supported
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2683    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Make User in the Device    n1    ${user1.name}    ${user1.password}    ${user1.role}
    Make User in the Device    n1    ${user2.name}    ${user2.password}    ${user2.role}
    cli    n1    configure
    cli    n1    exit
    ${output}    cli    n1    show running-config aaa user   prompt=${eutpmt}
    Result Should Contain    ${output}    ${user1.name} ${user2.name}
    Delete User in the Device    n1    ${user1.name}
    Delete User in the Device    n1    ${user2.name}
    cli    n1    configure
    cli    n1    exit
    ${output}    cli    n1    show running-config aaa user   prompt=${eutpmt}
    Result Should Not Contain    ${user1.name} ${user2.name}
    cli    n1    show running-config aaa user sysadmin   prompt=${eutpmt}
    Result Should Contain    sysadmin

*** Keywords ***
AXOS_E72_PARENT-TC-2683 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2683 setup

AXOS_E72_PARENT-TC-2683 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2683 teardown
    Disconnect    n1
