*** Settings ***
Documentation     The EXA Device must appear to perform the entire user authentication procedure, even if the user ID that is entered is not valid.
Test Setup        AXOS_E72_PARENT-TC-2688 setup
Test Teardown     AXOS_E72_PARENT-TC-2688 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
tc_EXA_device_MUST_perform_the_entire_login_process_irrespective_of_whether_the_user_id_is_valid_or_not
    [Documentation]    1 Do ssh on the device
    ...    2 give wrong user name it should accept
    ...    3 verify that should perform the entire login process(ask password)
    [Tags]    @TCID=AXOS_E72_PARENT-TC-2688    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    Log    "Correct user and wrong password"
    Make a Connection     n2    ${user3.name}    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n2    cli

*** Keywords ***
AXOS_E72_PARENT-TC-2688 setup
    log    Enter AXOS_E72_PARENT-TC-2688 setup
    Make User in the Device    n1    ${user3.name}    ${user3.password}    ${user3.role}

AXOS_E72_PARENT-TC-2688 teardown
    log    Enter AXOS_E72_PARENT-TC-2688 teardown
    Disconnect    n1
    Session Destroy Local    n2
    Delete User in the Device    n1    ${user3.name}
