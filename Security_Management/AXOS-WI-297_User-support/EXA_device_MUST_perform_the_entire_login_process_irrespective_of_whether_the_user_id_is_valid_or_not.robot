*** Settings ***
Documentation     EXA device MUST perform the entire login process irrespective of whether the user id is valid or not
Test Setup        AXOS_E72_PARENT-TC-2694 setup
Test Teardown     AXOS_E72_PARENT-TC-2694 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
EXA_device_MUST_perform_the_entire_login_process_irrespective_of_whether_the_user_id_is_valid_or_not
    [Documentation]    1 Do ssh on the device
    ...    2 give wrong user name it should accept
    ...    3 verify that should perform the entire login process(ask password)
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2694    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Log    "Correct user and wrong password"
    cli    n1    ssh wrongname@${DEVICES.n1.ip}    prompt=password:    timeout_exception=0
    cli    n1    no    timeout_exception=0
    cli    n1    password    prompt=password:    timeout_exception=0
    cli    n1    password    prompt=password:    timeout_exception=0
    cli    n1    password    prompt=password:    timeout_exception=0
    cli    n1    ssh {DEVICES.n1.user}@${DEVICES.n1.ip}    prompt=password:    timeout_exception=0
    cli    n1    no    timeout_exception=0
    cli    n1    password    prompt=#

*** Keywords ***
AXOS_E72_PARENT-TC-2694 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 setup
    Make User in the Device    n1    ${user3.name}    ${user3.password}    ${user3.role}

AXOS_E72_PARENT-TC-2694 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2694 teardown
    Disconnect    n1
