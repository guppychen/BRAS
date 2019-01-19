*** Settings ***
Documentation     This test suite is going to verify whether the active alarms can be acknowledged.
Suite Setup       alarm_setup    n1     n1_sh
Suite Teardown    alarm_teardown    n1     n1_sh
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***

Alarm_acknowledged_status
    [Documentation]    Test case verifies Active alarms is acknowledgeable
    ...                1. Trigger an alarm and find the alarm instance id. show alarm active.
    ...                2. Manually acknowledge the alarm based on the instance id. manual acknowledge instance-id x.x
    ...                3. Verify acknowledged alarm indicates who acknowledged it, when it was acknowledged and why it was acknowledged (Not Supported)
    ...                4. Verify alarm can be unacknowledged.(Not Supported)
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2837    @functional    @priority=P2       @user_interface=CLI      @runtime=short

    Log         *** Verifying alarm got acknowledged ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1


*** Keyword ***
alarm_setup
    [Arguments]    ${device1}    ${linux}
    [Documentation]         Triggering alarm for INFO severity

    Log    *** Trigerring one INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec      Clear running-config INFO alarm     ${device1}     ${linux}     cli
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO     ${device1}     ${linux}     cli


alarm_teardown
    [Arguments]    ${device1}     ${linux}
    [Documentation]        Clearing INFO alarm

    Log         *** Clearing INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}     ${linux}     cli
