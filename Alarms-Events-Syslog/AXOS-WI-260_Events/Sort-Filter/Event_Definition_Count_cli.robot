*** Settings ***
Documentation     This test suite is going to verify whether the event definitions are shown as per count.
Suite Setup       event definition total count    n1
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***
Event_Definition_Count
    [Documentation]    Test case verifies event definitions are shown as per count via CLI
    ...                1 Retrieve events and filter on total count.  Verify by show events and make sure events are shown as per count
    ...                2 Retrieve events and filter on count by with appropriate command  Verify by show events and make sure events are shown as starting from starting number to the number needed for display.
    ...                3 Retrieve events and filter on count by with appropriate command, make sure give start count  Make sure it does'nt error and does'nt crash the system
    [Tags]           @tcid=AXOS_E72_PARENT-TC-2870    @functional    @priority=P2     @user_interface=CLI

    Log    *** Verify Event definition displayed as per count ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Event definition displayed as per count     n1     ${total_count}

*** Keyword ***
event definition total count
    [Arguments]    ${device1}
    [Documentation]      Getting Event definition total count

    Log    *** Getting Event definition total count ***
    ${total_count}      Getting Event definition total count     ${device1}
    Set Suite Variable    ${total_count}    ${total_count}
