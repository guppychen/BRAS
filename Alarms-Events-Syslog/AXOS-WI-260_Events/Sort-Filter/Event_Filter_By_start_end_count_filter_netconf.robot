*** Settings ***
Documentation     This test suite is going to verify whether the events are shown as per count and between ranges
Suite Setup       event total count    n1_netconf
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

*** Test Cases ***
Event_Filter_By_start_end_count_filter
    [Documentation]    Test case verifies events are shown as per count and between ranges via netconf
    ...                1. Retrieve events and filter on count .  Verify by show events and make sure events are shown as per count
    ...                2. Retrieve events and filter on count by  with appropriate command Verify by show events and make sure events are shown as starting from starting number to the number needed for display.
    ...                3. Retrieve events and filter on count by  with appropriate command, make sure give start count 0 Make sure it does'nt error and does'nt crash the system
    ...                4. Retrieve all events without filter  verify by show command and make sure all the events are displayed
    [Tags]            @tcid=AXOS_E72_PARENT-TC-2874    @functional    @priority=P2       @user_interface=netconf

    Log         *** Verify Events are displayed as per count and for count 0 ***
    Run Keyword And Continue On Failure     Verify Events are displayed as per count using netconf    n1_netconf     ${total_count}

    Log         *** Verify events filter by range ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify events filter by range using netconf    n1_netconf    ${total_count}

*** Keyword ***
event total count
    [Arguments]    ${device1}
    [Documentation]    Getting all Active events without any filter and get the total count

    Log         *** Clearing and Trigerring event ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing and Trigerring event using netconf       ${device1}

    Log         *** Getting all Active events without any filter and get the total count ***
    ${total_count}    Getting Active events total count using netconf      ${device1}
    Set Suite Variable    ${total_count}    ${total_count}

