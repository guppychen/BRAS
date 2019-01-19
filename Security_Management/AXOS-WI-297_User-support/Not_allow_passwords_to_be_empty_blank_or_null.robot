*** Settings ***
Documentation     Not allow passwords to be empty, blank or null
Test Setup        AXOS_E72_PARENT-TC-2691 setup
Test Teardown     AXOS_E72_PARENT-TC-2691 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Not_allow_passwords_to_be_empty_blank_or_null
    [Documentation]    1 Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters.
    ...    2 Leave the password blank,Should not allow creating a blank or empty password
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2691    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1    configure
    cli    n1    aaa user ${user1.name}    timeout_exception=0
    cli    n1    \    timeout_exception=0
    cli    n1    ${user1.role}    timeout_exception=0    prompt= password
    Result Should Contain    Aborted:

*** Keywords ***
AXOS_E72_PARENT-TC-2691 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2691 setup
    cli  n1     configure
    cli  n1     no aaa user ${user1.name}
AXOS_E72_PARENT-TC-2691 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2691 teardown
    cli    n1    no aaa user ${user1.name}
    Disconnect    n1
