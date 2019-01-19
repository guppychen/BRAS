*** Settings ***
Documentation     This test suite is going to verify whether the event definitions are filtered as per the given input filter list.
Suite Setup       event definition total count    n1
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***
Event_Definition_Filter
    [Documentation]    Test case verifies event definitions are filtered as per the given input filter list
    ...                1 Retrieve events and filter on count.  Verify by show events and make sure events are shown as per count
    ...                2 Retrieve events and filter on id
    ...                3 Retrieve events and filter on name
    ...                4 Retrieve events and filter on category
    [Tags]             @tcid=AXOS_E72_PARENT-TC-2866    @functional    @priority=P3       @user_interface=CLI      @skip=step_skipped

    Log    *** Verify Event definition displayed as per count ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Event definition displayed as per count     n1     ${total_count}

    Log    *** Verify Event definition displayed as per given id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by id       n1     ${total_count}

    Log    *** Verify Event definition displayed as per given name ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by name     n1     ${total_count}

    Log    *** Verify Event definition displayed as per given category ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by category     n1     ${total_count}

    #Log    *** Verify Event definition displayed as per given address ***
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by address     n1

*** Keyword ***
event definition total count
    [Arguments]    ${device1}
    [Documentation]      Getting Event definition total count

    Log    *** Getting Event definition total count ***
    ${total_count}      Getting Event definition total count     ${device1}
    Set Suite Variable    ${total_count}    ${total_count}
