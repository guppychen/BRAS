*** Settings ***
Documentation     Default System Admin user profile with system Admin role profile
Test Setup        AXOS_E72_PARENT-TC-2677 setup
Test Teardown     AXOS_E72_PARENT-TC-2677 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
Default_System_Admin_user_profile_with_system_Admin_role_profile
    [Documentation]    1Log in as sysadmin
    ...    2 show system administrator user profile with sysadmin role profile as supportedt
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2677    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    cli    n1    configure
    cli    n1    aaa user sysadmin role    timeout_exception=0
    Result Should Contain    admin

*** Keywords ***
AXOS_E72_PARENT-TC-2677 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2677 setup

AXOS_E72_PARENT-TC-2677 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2677 teardown
    Disconnect    n1
