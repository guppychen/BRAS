*** Settings ***
Documentation     Users can't be deleted if currently logged in
Test Setup        AXOS_E72_PARENT-TC-2674 setup
Test Teardown     AXOS_E72_PARENT-TC-2674 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Variables ***

*** Test Cases ***
tc_Management_Interfaces_Security_Security_Permissions_Deletion_of_Current_logged_in_user
    [Documentation]    1 Login as sysadmin login successful
    ...    2 add role oper to tac default user role added to user
    ...    3 try to delete sysadmin user and see that this is not allowed generates error messafge
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2674    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    Log    step1:login the device
    cli    n1    cli
    Command    n1    configure
    Log    step2:add role oper to tac default user
    Command    n1    aaa user tac role oper
    ${user_added}    Command    n1    aaa user tac role    timeout=5    timeout_exception=0
    Should Contain    ${user_added}    oper
    Log    step3:try to delete sysadmin user and see that this is not allowed
    ${flag}    Command    n1    no aaa user sysadmin
    Comment    Fails if the sysadmin gets removed
    Should Contain Any    ${flag}    Aborted: illegal reference 'aaa user tac role'    Invalid role aaa

*** Keywords ***
AXOS_E72_PARENT-TC-2674 setup
    log    Enter AXOS_E72_PARENT-TC-2674 setup

AXOS_E72_PARENT-TC-2674 teardown
    log    Enter AXOS_E72_PARENT-TC-2674 teardown
    Command    n1    aaa user tac role admin
    Command    n1    no aaa user tac role oper
    command    n1    end