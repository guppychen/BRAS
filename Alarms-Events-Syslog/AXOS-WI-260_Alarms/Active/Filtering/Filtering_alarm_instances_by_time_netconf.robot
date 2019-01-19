*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be filtered by time.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Library           DateTime
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support   @author=ssekar

*** Test Cases ***
Filtering_alarm_instances_by_time
    [Documentation]    Test case verifies Active alarms filtered from start time to end time
    ...                1. Generate various active alarms. Alarms are shown in the active alarm log. show alarm active
    ...                2. Use the show alarm active timerange command to filter alarms based on zulu time (absolute format is like 2015-11-15T05:15:00Z). Only alarms in the time range are displayed. show alarm active timerange
    [Tags]      @tcid=AXOS_E72_PARENT-TC-2841    @functional    @priority=P2     @user_interface=netconf

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count using netconf    n1_netconf

    Log    *** Verifying Active alarms filtered by time ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying alarms filtered by time using netconf    n1_netconf     ${total_count}    active

