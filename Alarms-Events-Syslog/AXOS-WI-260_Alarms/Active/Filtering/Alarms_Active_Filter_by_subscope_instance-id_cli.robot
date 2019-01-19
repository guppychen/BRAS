*** Settings ***
Documentation     This test suite is going to verify whether Active alarms can be filtered using subscope instance-id.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support  @author=ssekar

*** Test Cases ***

Alarms_Active_Filter_by_subscope_instance-id
    [Documentation]    Test case verifies Active alarms filtered by subscope instance-id.
    ...                1. Use show alarms filter command and filter by subscope instance-id.  Verify alarms are displayed for various Instance ID's.
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2851      @functional    @priority=P2      @user_interface=CLI

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count    n1

    Log    *** Verifying Active alarms gets filtered using subscope instance-id ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying Active Alarm subscope gets filtered using instance-id      n1        ${total_count}


