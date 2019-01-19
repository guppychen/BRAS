*** Settings ***
Documentation     Management Plane Security/No indication of Username or password wrong if a login attempt fail logs of any form, events) passwords used for authentication; either successfully or failed.
Test Setup        AXOS_E72_PARENT-TC-2692 setup
Test Teardown     AXOS_E72_PARENT-TC-2692 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Variables ***

*** Test Cases ***
Management_Plane_Security_No_indication_of_Username_or_password_wrong_if_login_attempt_fail
    [Documentation]    1 Enter valid username with corresponding wrong password login failed
    ...    2 Enter a wrong username with wrong password login failed
    ...    3 Enter wrong username with corresponding valid password login failed
    ...    4 Enter correct username with corresponding correct password login succesfull
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2692    @feature=AXOS-WI-297 User Support    @EUT=E3-2    @priority=1
    Log    "Correct user and wrong password"
    Make a Connection    n2    ${user3.name}    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n2    cli
    Log    "Incorrect user and correct password"
    Make a Connection    n3    wronguser    ${user1.password}
    Run Keyword And Expect Error    SSHLoginException    cli    n3    cli
    Log    "Incorrect user and Incorrect password"
    Make a Connection    n4    wronguser    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n4    cli
    Log    "Correct user and password"
    Make a Connection    n5    ${user1.name}    ${user1.password}

*** Keywords ***
AXOS_E72_PARENT-TC-2692 setup
    [Documentation]    Will Setup the test case by creating Users required for test case.
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2692 setup
    Make User in the Device    n1    ${user3.name}    ${user3.password}    ${user3.role}

AXOS_E72_PARENT-TC-2692 teardown
    [Documentation]    Will Delete the users that were made in the Setup.
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2692 teardown
    Disconnect    n1
    Session Destroy Local    n2
    Session Destroy Local    n3
    Session Destroy Local    n4
    Session Destroy Local    n5
    Delete User in the Device    n1    ${user3.name}

13740
