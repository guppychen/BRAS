*** Settings ***
Documentation     EXA device MUST support a default Monitor user profile named "monitor" with the operator role profile
Test Setup        AXOS_E72_PARENT-TC-2686 setup
Test Teardown     AXOS_E72_PARENT-TC-2686 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Variables ***

*** Test Cases ***
tc_EXA_device_MUST_support_a_default_Monitor_user_profile_named_monitor_with_the_operator_role_profile
    [Documentation]    1 login as sysadmin login successfully
    ...    2 check default user profile "monitor" role is oper verify this user role is monitor
    ...    3 login as monitor login successfully
    ...    4 check this user support read operation of the device this user will read all show commands without error
    [Tags]    @author=vduraira    @TCID=AXOS_E72_PARENT-TC-2686    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    cli    n1    cli
    cli    n1    configure
    log    STEP:2 check default user profile "monitor" role is oper verify this user role is monitor
    cli    n1    aaa user monitor role    timeout_exception=0
    Result Should Contain    oper
    log    STEP:3 login as monitor
    Make User in the Device    n1    ${user4.name}    ${user4.password}    ${user4.role}
    Make a Connection    n2    ${user4.name}    ${user4.password}
    cli    n2    cli
    log    STEP:4 check this user support read operation of the device this user will read all show commands without error
    ${check}=    cli    n2    show ?    newline=q
    Should Contain    ${check}    Possible completions:

*** Keywords ***
AXOS_E72_PARENT-TC-2686 setup
    log    Enter AXOS_E72_PARENT-TC-2686 setup

AXOS_E72_PARENT-TC-2686 teardown
    log    Enter AXOS_E72_PARENT-TC-2686 teardown
    Session Destroy Local    n2
