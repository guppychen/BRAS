*** Settings ***
Documentation     To check different users can login through SSH when all radius servers are down. Multiple users sessions logged in when all radius server down
...
...               Step 1: Login using session n1 and log the user id count.
...               Step 2: Make another user n2 and Log in into the device.
...               Step 3: Repeat step 2 for n3,n4 and n5.
...               Step 4: Log the present user id count.
...               Step 5: Validate the initial and final count of users.
Test Setup        setup
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Variables ***

*** Test Cases ***
All RADIUS server are not reachable through out of band access
    [Documentation]    Multiple users should be able to login.
    [Tags]    @author=sandeep awatade    @tcid=AXOS_E72_PARENT-SSH-10    @globalid=1686805    @eut=NGPON2-4    @priority=p1
    cli    n1    cli
    ${usr1}    cli    n1    show user-sessions session    prompt=#    timeout=10
    ${session1}    Get Lines Containing String    ${usr1}    session-id
    ${users1}    Get Line Count    ${session1}
    Comment    Initial User Count
    Comment    ${users1}    Convert To Number    ${users1}
    Log    ${users1}
    Make User in the Device    n1    ${user1.name}    ${user1.password}
    Make User in the Device    n1    ${user2.name}    ${user2.password}
    Make User in the Device    n1    ${user3.name}    ${user3.password}
    Make User in the Device    n1    ${user4.name}    ${user4.password}
    Make a Connection and Login    n2    ${user1.name}    ${user1.password}
    Make a Connection and Login    n3    ${user2.name}    ${user2.password}
    Make a Connection and Login    n4    ${user3.name}    ${user3.password}
    Make a Connection and Login    n5    ${user4.name}    ${user4.password}
    Comment    User Count After four user Log in the box.
    ${users}    cli    n5    show user-sessions session    prompt=#    timeout=10    timeout_exception=0
    ${session}=    Get Lines Containing String    ${users}    session-id
    ${users}=    Get Line Count    ${session}
    Comment    ${users}    Convert To Number    ${users}
    Comment    Fails if the user count is less
    Run Keyword If    '${users}' < '${users1}'    Fail

*** Keywords ***
setup
    [Documentation]    Configure Radius Server In the DUT.
    cli    n1    cli
    cli    n1    conf
    cli    n1    aaa authentication-order radius-then-local
    cli    n1    aaa radius retry 1
    Comment    Dummy Radius Server
    cli    n1    aaa radius server 1.1.1.1 secret secret
    cli    n1    aaa radius server 2.2.2.2 secret test_radius_server
    Disconnect    n1

teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    cli    n1    cli
    cli    n1    conf
    cli    n1    no aaa authentication-order
    cli    n1    no aaa radius retry
    cli    n1    no aaa radius server 1.1.1.1
    cli    n1    no aaa radius server 2.2.2.2
    Disconnect    n1
    Session Destroy Local    n2
    Session Destroy Local    n3
    Session Destroy Local    n4
    Session Destroy Local    n5
    Delete User in the Device    n1    ${user1.name}    ${user1.password}
    Delete User in the Device    n1    ${user2.name}    ${user2.password}
    Delete User in the Device    n1    ${user3.name}    ${user3.password}
    Delete User in the Device    n1    ${user4.name}    ${user4.password}
