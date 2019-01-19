*** Settings ***
Documentation     This test suite is going to verify whether events are filtered by all options - by name, ID, instance-id, and time.
Suite Setup       event_setup      n1_netconf
Library           String
Library           Collections
Resource          base.robot
Force Tags

*** Test Cases ***
Event_Filters
    [Documentation]    Test case verifies events are filtered by all options via CLI
    ...                1. Generate various events. Verify events can be filtered with each criteria.
    [Tags]          @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2869    @functional    @priority=P2       @user_interface=netconf

    Log         *** Verifying events can be filtered with each criteria ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event filter list using netconf     n1_netconf

*** Keyword ***

event_setup
    [Arguments]    ${device1}
    [Documentation]    Trigerring event

    Log         *** Clearing and Trigerring event ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing and Trigerring event using netconf       ${device1}
