*** Settings ***
Documentation     SSH sessions MUST take users directly to an E3-2 CLI session
...
...               Step 1: Login using session n1 and validate login using cli command.
Test Teardown     teardown
Force Tags        @feature=Management    @subFeature=SSH    @author=cindy gao
Resource          base.robot

*** Variables ***

*** Test Cases ***
SSH sessions MUST take users directly to a CLI session
    [Documentation]    User should be taken to a cli session.
    [Tags]    @author=sandeep awatade    @tcid=AXOS_E72_PARENT-SSH-2    @globalid=1541548    @eut=NGPON2-4    @priority=p1
    #User in the cli mode
    Make User in the Device    n1    ${user1.name}    ${user1.password}
    Make a Connection and Login    n2    ${user1.name}    ${user1.password}
    ${result}    cli    n2    show version    prompt=#
    Should Not Contain    ${result}    error

*** Keywords ***
teardown
    [Documentation]    Test Case specific Teardown to delete user and reset the device back to original state.
    Disconnect    n2
    Destroy Local    n2
    Delete User in the Device    n1    ${user1.name}    ${user1.password}
