*** Settings ***
Documentation     EXA device MUST never display login passwords in clear text
Test Setup        AXOS_E72_PARENT-TC-2690 setup
Test Teardown     AXOS_E72_PARENT-TC-2690 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
EXA_device_MUST_never_display_login_passwords_in_clear_text
    [Documentation]    1Create a user using the user access interfacesa
    ...    2 Login to the system using the user account
    ...    3 Verify that the login passwords are never displayed using clear text
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2690    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1    configure
    cli    n1    aaa user ${user1.name}    prompt=>\\):    timeout=30
    ${check}    cli    n1    ${user1.password}       prompt=\\):       timeout=30
    cli    n1    ${user1.role}   timeout=30
    Log    ${check}
    Should Not Contain    ${check}    ${user1.password}

*** Keywords ***
AXOS_E72_PARENT-TC-2690 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2690 setup
    cli    n1    configure
    cli    n1    no aaa user ${user1.name}
AXOS_E72_PARENT-TC-2690 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2690 teardown
    cli    n1    no aaa user ${user1.name}
    Disconnect    n1
