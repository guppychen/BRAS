*** Settings ***
Documentation     To check single user can login through SSH.
...
...               Step 1: Login using session n1.
...               STep 2: Validate the login using any cli Command.
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Variables ***

*** Test Cases ***
Single user session should be estabilished using SSH
    [Documentation]    Single user should be able to SSH the device.
    [Tags]    @author=sandeep awatade    @globalid=1759502    @tcid=AXOS_E72_PARENT-SSH-11    @eut=NGPON2-4    @priority=p1
    Log    *** Enter the device ***
    Cli    n1    cli
    Command    n1    show version
    Result Should Not Contain    error
    Command    n1    show user-sessions session    prompt=#
    Result Should Not Contain    error

*** Keywords ***
teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    Disconnect    n1
