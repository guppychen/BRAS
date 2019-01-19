*** Settings ***
Documentation     To check whether user session gets terminated when the user exits.
...
...               Step 1: Login using session n1.
...               Step 2: Make another user n2 and Log in into the device.
...               Step 3: Check the user count.
...               Step 4: Disconnect from n2.
...               Step 5: Check the user count and validate.
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Variables ***
${second_user}    n_2

*** Test Cases ***
Exiting a CLI session MUST terminate the SSH session that was used to access the CLI
    [Documentation]    User exit from the session then the session should also be terminated.
    [Tags]    @author=sandeep awatade    @tcid=AXOS_E72_PARENT-SSH-3    @globalid=1541549    @eut=NGPON2-4    @priority=p1
    Log    *** Enter the device ***
    Cli    n1    cli
    Log    *** Check current running user sessions***
    ${usr1}=    Command    n1    show user-sessions session    timeout_exception=0    prompt=#
    ${session1}=    Get Lines Containing String    ${usr1}    session-id
    ${users1}=    Get Line Count    ${session1}
    Log    ${users1}
    Log    ***SECOND USER ***
    Make User in the Device    n1    ${user1.name}    ${user1.password}
    #To counter the signout for the the above keyword
    Cli    n1    cli
    Make a Connection and Login    ${second_user}    ${user1.name}    ${user1.password}
    ${user2}=    Command    ${second_user}    show user-sessions session    timeout_exception=0    prompt=#
    ${session2}=    Get Lines Containing String    ${user2}    session-id
    ${users2}=    Get Line Count    ${session2}
    Log    ${users2}
    Comment    Failure will occur if the user count dont increase.
    Run Keyword If    ${users2}<=${users1}    Fail
    Destroy Local    ${second_user}
    ${user3}=    Command    n1    show user-sessions session    timeout_exception=0    prompt=#
    ${session3}=    Get Lines Containing String    ${user3}    session-id
    ${users3}=    Get Line Count    ${session3}
    Log    ${users3}
    Run Keyword If    ${users3}!=${users1}    Fail

*** Keywords ***
teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    Session Destroy Local    ${second_user}
    Disconnect    n1
    Delete User in the Device    n1    ${user1.name}    ${user1.password}
