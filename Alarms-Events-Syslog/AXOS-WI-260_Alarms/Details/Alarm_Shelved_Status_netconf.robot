*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be shelved and un-shelved using netconf.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Library           XML    use_lxml=True
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar


*** Test Cases ***

Alarm_Shelved_Status
    [Documentation]    Test case verifies Alarms can be shelved and un-shelved
    ...    1. Verify alarms can be shelved and show who shelved it, when it was shelved and why it was shelved. manual shelve instance-id X.  
    ...    2. Verify alarms can be un-shelved and show who and when it was un-shelved. (who,when,why - Not Supported)
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2712    @functional    @priority=P2        @user_interface=NETCONF      @runtime=short

    Log    *** Verifying Alarms can be shelved and un-shelved ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf       n1_netconf      

