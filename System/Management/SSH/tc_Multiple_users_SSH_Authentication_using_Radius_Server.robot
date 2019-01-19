*** Settings ***
Documentation     To check different users can login using Radius Server
...
...               Step 1: Login using session n1 and log the user id count.
...               Step 2: Make another user n2 and Log in into the device.
...               Step 3: Validate the initial and final count of users.
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Variables ***

*** Test Cases ***
Multiple users SSH Authentication using Radius Server
    [Documentation]    Radius user logging the device
    [Tags]    @author=sandeep awatade    @tcid=AXOS_E72_PARENT-SSH-14    @globalid=1759505    @eut=NGPON2-4    @priority=p1
    Log    *** Enter the device ***
    Make User in the Device    n1    ${user5.name}    ${user5.password}
    Cli    n1    cli
    Log    *** Check current running user sessions***
    ${user1}=    Command    n1    show user-sessions session    prompt=#
    ${session1}=    Get Lines Containing String    ${user1}    session-id
    ${users1}=    Get Line Count    ${session1}
    Log    ${users1}
    Log    ***SECOND USER ***
    Make a Connection and Login    n2    ${user5.name}    ${user5.password}
    ${user2}=    Command    n2    show user-sessions session    timeout_exception=0    prompt=#
    ${session2}=    Get Lines Containing String    ${user2}    session-id
    ${users2}=    Get Line Count    ${session2}
    Log    ${users2}
    Run Keyword If    ${users2}<=${users1}    Fail

*** Keywords ***
teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    Session Destroy Local    n2
    Disconnect    n1
    Delete User in the Device    n1    ${user5.name}    ${user5.password}
