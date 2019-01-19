*** Settings ***
Documentation     Authentication fails using radius server through out of band access
...
...               Step 1: Login using session n1 and Make a Valid User.
...               Step 2: Make another session n2 with wrong password and validate login.
...               Step 3: Make another session n3 with wrong user and validate login.
...               Step 4: Make another session n4 with wrong password and wrong user and validate login.
...               Step 5: Make another session n1 with correct user and password and validate login.
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Test Cases ***
Authentication fails using radius server through out of band access
    [Documentation]    Authentication fails using radius server through out of band access
    [Tags]    @author=sandeep awatade    @tcid=AXOS_E72_PARENT-SSH-8    @globalid=1686803    @eut=NGPON2-4    @priority=p1
    Make User in the Device    n1    ${user1.name}    ${user1.password}
    Comment    "Correct user and wrong password"
    Make a Connection    n2    ${user1.name}    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n2    cli
    Comment    "Incorrect user and correct password"
    Make a Connection    n3    wronguser    ${user1.password}
    Run Keyword And Expect Error    SSHLoginException    cli    n3    cli
    Comment    "Incorrect user and Incorrect password"
    Make a Connection    n4    wronguser    wrongpassword
    Run Keyword And Expect Error    SSHLoginException    cli    n4    cli
    Comment    "Correct user and password"
    Make a Connection and Login    n5    ${user1.name}    ${user1.password}

*** Keywords ***
teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    Disconnect    n1
    Session Destroy Local    n2
    Session Destroy Local    n3
    Session Destroy Local    n4
    Session Destroy Local    n5
    Delete User in the Device    n1    ${user1.name}    ${user1.password}
