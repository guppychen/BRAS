*** Settings ***
Documentation     Authorization is a process of determining what permissions
Test Setup        AXOS_E72_PARENT-TC-2682 setup
Test Teardown     AXOS_E72_PARENT-TC-2682 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Authorization_is_a_process_of_determining_what_permissions
    [Documentation]    1Create a user using the user access interfacesa
    ...    2 Login to the system using the user account
    ...    3 Verify that the login passwords are never displayed using clear text
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2682    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1_session4    cli
    cli    n1_session4    show ?
    Result Should Contain    Description: Show object data
    cli    n1_session4    configure
    Result Should Contain    syntax error:

*** Keywords ***
AXOS_E72_PARENT-TC-2682 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2682 setup

AXOS_E72_PARENT-TC-2682 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2682 teardown
