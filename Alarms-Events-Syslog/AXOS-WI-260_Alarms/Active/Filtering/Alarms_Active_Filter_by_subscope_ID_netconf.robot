*** Settings ***
Documentation     This test suite is going to verify whether Active alarms can be filtered using subscope ID.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support  @author=ssekar

*** Test Cases ***

Alarms_Active_Filter_by_subscope_ID
    [Documentation]    Test case verifies Active alarms filtered by subscope ID.
    ...                1. Use show alarms filter command and filter by subscope ID.  Verify alarms are displayed for various IDs. show alarm active subscope ID
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2849      @functional    @priority=P2      @user_interface=netconf

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count using netconf    n1_netconf

    Log    *** Verifying Active alarms gets filtered using subscope ID ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying Active Alarm subscope gets filtered by ID using netconf        n1_netconf        ${total_count}

