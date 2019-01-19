*** Settings ***
Documentation     This test suite is going to verify whether the events can be filtered by source
Suite Setup       alarm_setup     n1
Library           String
Library           Collections
Resource          base.robot
Force Tags

*** Test Cases ***

Event_Filters_bykeyword
    [Documentation]    Test case verifies events can be filtered by source
    ...                1. Retrieve events and filter on source  Verify by show command 
    [Tags]         @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2872    @functional    @priority=P3       @user_interface=cli

    Log         *** Verify Events can be filtered by source ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds        Events_filter_by_source      n1      ${DEVICES.n1.user}


*** Keyword ***

alarm_setup
    [Arguments]    ${device1}
    [Documentation]    Triggering event for user login and logout

    Log         *** Triggering event for user login and logout ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering_event_for_user_login_logout     ${device1}
