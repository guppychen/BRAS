*** Settings ***
Documentation     This test suite is going to verify whether events are filtered by all options - by name, ID, instance-id, and time.
Suite Setup       event_setup      n1
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

*** Test Cases ***
Event_Filters
    [Documentation]    Test case verifies events are filtered by all options via CLI
    ...                1. Generate various events. Verify events can be filtered with each criteria.
    [Tags]    testtest         @tcid=AXOS_E72_PARENT-TC-2868    @functional    @priority=P2       @user_interface=CLI

    Log         *** Verifying events can be filtered with each criteria ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event filter list     n1

*** Keyword ***

event_setup
    [Arguments]    ${device1}
    [Documentation]    Trigerring event

    Log         *** Trigerring events ***
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring event    ${device1}
