*** Settings ***
Documentation     No bypass the authentication, authorization and ACL mechanisms
Test Setup        AXOS_E72_PARENT-TC-2693 setup
Test Teardown     AXOS_E72_PARENT-TC-2693 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
No_bypass_the_authenticatio_authorization_and_ACL_mechanisms
    [Documentation]    1 Create a user using the user agent interfaces that consists of Capital and small alpabets and some alphanumeric characters.
    ...    2 Leave the password blank,Should not allow creating a blank or empty password
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2693    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1    configure
    cli    n1_session1    show version
    Result Should Not Contain    error
    cli    n1_session2    show version
    Result Should Not Contain    error
    cli    n1_session3    show version
    Result Should Not Contain    error
    cli    n1_session4    show version
    Result Should Not Contain    error

*** Keywords ***
AXOS_E72_PARENT-TC-2693 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2693 setup
    cli    n1    configure
    cli    n1    aaa user tac password admin role admin    timeout_exception=0
AXOS_E72_PARENT-TC-2693 teardown
    [Documentation]
    [Arguments]
    Disconnect    n1_session1
    Disconnect    n1_session2
    Disconnect    n1_session3
    Disconnect    n1_session4
