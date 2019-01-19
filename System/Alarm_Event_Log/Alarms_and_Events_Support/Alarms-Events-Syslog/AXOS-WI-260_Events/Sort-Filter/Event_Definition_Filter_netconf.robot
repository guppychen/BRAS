*** Settings ***
Documentation     This test suite is going to verify whether the event definitions are filtered as per the given input filter list.
Suite Setup       event definition total count    n1_netconf
Library           String
Library           Collections
Resource          base.robot
Force Tags

*** Test Cases ***
Event_Definition_Filter
    [Documentation]    Test case verifies event definitions are filtered as per the given input filter list
    ...                1 Retrieve events and filter on count.  Verify by show events and make sure events are shown as per count
    ...                2 Retrieve events and filter on id
    ...                3 Retrieve events and filter on name
    ...                4 Retrieve events and filter on category
    [Tags]        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar     @tcid=AXOS_E72_PARENT-TC-2867    @functional    @priority=P3       @user_interface=netconf      @skip=step_skipped

    Log    *** Verify Event definition displayed as per count ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Event definition displayed as per count using netconf     n1_netconf     ${total_count}

    Log    *** Verify Event definition displayed as per given id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by id using netconf      n1_netconf     ${total_count}

    Log    *** Verify Event definition displayed as per given name ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by name using netconf    n1_netconf     ${total_count}

    Log    *** Verify Event definition displayed as per given category ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by category using netconf     n1_netconf     ${total_count}

    #Log    *** Verify Event definition displayed as per given address ***
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying event definition filter by address using netconf    n1_netconf

*** Keyword ***
event definition total count
    [Arguments]    ${device1}
    [Documentation]      Getting Event definition total count

    Log    *** Getting Event definition total count ***
    ${total_count}      Getting Event definition total count using netconf     ${device1}
    Set Suite Variable    ${total_count}    ${total_count}
