*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be acknowledged using netconf.
Suite Setup       alarm_setup    n1_netconf       n1_sh
Suite Teardown    alarm_teardown    n1_netconf    n1_sh
Library           String
Library           Collections
Library           XML    use_lxml=True
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar


*** Test Cases ***

Alarm_acknowledged_status
    [Documentation]    Test case verifies Active alarms are acknowledgeable using netconf
    ...    1. Trigger an alarm and find the alarm instance id. show alarm active.
    ...    2. Manually acknowledge the alarm based on the instance id. manual acknowledge instance-id x.x
    ...    3. Verify acknowledged alarm indicates who acknowledged it, when it was acknowledged and why it was acknowledged (Not Supported)
    ...    4. Verify alarm can be unacknowledged.(Not Supported)
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2837    @functional    @priority=P2        @user_interface=NETCONF     @runtime=short

    Log    *** Verifying alarm got acknowledged ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       name

*** Keyword ***
alarm_setup
    [Arguments]    ${device1}     ${linux}

    Log    *** Triggering anyone INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device1}     ${linux}    netconf

alarm_teardown
    [Arguments]    ${device1}    ${linux}

    Log    *** Clearing created INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device1}     ${linux}     netconf
