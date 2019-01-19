*** Settings ***
Documentation     EXA device MUST support passwords with alphanumeric and special characters.
Test Setup        AXOS_E72_PARENT-TC-2696 setup
Test Teardown     AXOS_E72_PARENT-TC-2696 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
EXA_device_MUST_support_passwords_with_alphanumeric_and_special_characters
    [Documentation]    1 Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters
    ...    2 Create a password that consists of only Alphanumeric characters
    ...    3 Create a password that consists of only special characters
    ...    4 Create a password with both alphanumeric and special characters
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2696    @EUT=E3-2    @priority=1
    Comment    EXA device MUST support passwords with alphanumeric and special characters
    Make User in the Device    n1    ${user1.name}    Sp#@cial_Char#    ${user1.role}
    Make User in the Device    n1    ${user2.name}    Sp#@cial_Char#    ${user2.role}
    Make User in the Device    n1    ${user3.name}    Sp#@cial_Char#    ${user3.role}

*** Keywords ***
AXOS_E72_PARENT-TC-2696 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2696 setup

AXOS_E72_PARENT-TC-2696 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2696 teardown
    Delete User in the Device    n1    ${user1.name}
    Delete User in the Device    n1    ${user2.name}
    Delete User in the Device    n1    ${user3.name}
    Disconnect    n1
