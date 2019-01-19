*** Settings ***
Documentation     EXA Device must not provide any indication of whether it was the user name or password that was wrong if a login attempt fails for logins
Test Setup        AXOS_E72_PARENT-TC-2680 setup
Test Teardown     AXOS_E72_PARENT-TC-2680 teardown
Force Tags        @feature=AXOS-WI-297 User Support    @author=vduraira
Resource          base.robot

*** Test Cases ***
tc_Management_Interfaces_Security_Security_Permissions_Login_attempt_fails
    [Documentation]    1 Enter valid username with corresponding wrong password login failed no indication provided
    ...    2 Enter wrong username with corresponding valid password if username was correct login failed no indication provided
    ...    3 Enter a wrong username with wrong password login failed no indication provided
    ...    4 Enter correct username with corresponding correct password login successful
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2680    @feature=AXOS-WI-297 User Support    @EUT=E3-2
    Log    "Correct user and wrong password"
    Make a Connection    n2    ${user3.name}    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n2    cli
    Log    "Incorrect user and correct password"
    Make a Connection     n3    wronguser    ${user1.password}
    Run Keyword And Expect Error    SSHLoginException    cli    n3    cli
    Log    "Incorrect user and Incorrect password"
    Make a Connection     n4    wronguser    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n4    cli
    Log    "Correct user and password"
    Make a Connection    n5    ${user1.name}    ${user1.password}

*** Keywords ***
AXOS_E72_PARENT-TC-2680 setup
    log    Enter AXOS_E72_PARENT-TC-2680 setup

AXOS_E72_PARENT-TC-2680 teardown
    log    Enter AXOS_E72_PARENT-TC-2680 teardown
    Disconnect    n1
    Session Destroy Local    n2
    Session Destroy Local    n3
    Session Destroy Local    n4
    Session Destroy Local    n5
    Delete User in the Device    n1    ${user3.name}
