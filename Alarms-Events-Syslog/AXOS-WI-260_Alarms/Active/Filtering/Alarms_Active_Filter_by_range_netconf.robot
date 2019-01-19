*** Settings ***
Documentation     This test suite is going to verify whether the Active alarms can be filtered by range
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support    @author=ssekar

*** Test Cases ***

Alarms_Active_Filter_by_range
    [Documentation]    Test case verifies Active alarms filtered by range
    ...                1. Use show alarms filter command and filter by range.  Verify alarms are displayed for various ranges
    [Tags]          @tcid=AXOS_E72_PARENT-TC-2842    @functional    @priority=P2      @user_interface=netconf

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count using netconf    n1_netconf

    Log         *** Verify Active alarms filter by range ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Active alarms filter by range using netconf    n1_netconf     ${total_count}


