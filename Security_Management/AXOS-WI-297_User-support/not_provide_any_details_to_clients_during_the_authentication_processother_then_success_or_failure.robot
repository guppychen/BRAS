*** Settings ***
Documentation     not provide any details to clients during the authentication process other then success or failure
Test Setup        AXOS_E72_PARENT-TC-2689 setup
Test Teardown     AXOS_E72_PARENT-TC-2689 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
not_provide_any_details_to_clients_during_the_authentication_processother_then_success_or_failure
    [Documentation]    1 Do ssh or telnet on the device
    ...    2 give wrong username and wrong password
    ...    3 verify it shows only 'login incorrect'
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2689    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Log    "Correct user and wrong password"
    Make a Connection    n2    ${user3.name}    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n2    cli

*** Keywords ***
AXOS_E72_PARENT-TC-2689 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2689 setup

AXOS_E72_PARENT-TC-2689 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2689 teardown
    Session Destroy Local    n2
