*** Settings ***
Documentation     This test suite is going to verify whether Active alarms can be filtered using subscope name.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support  @author=ssekar

*** Test Cases ***

Alarms_Active_Filter_by_subscope_name
    [Documentation]    Test case verifies Active alarms filtered by subscope name.
    ...                1. Use show alarms filter command and filter by subscope name.  Verify alarms are displayed for various names. show alarm active subscope name
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2853      @functional    @priority=P2      @user_interface=CLI

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count    n1

    Log    *** Verifying Active alarms gets filtered using subscope name ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying Active Alarm subscope gets filtered using name      n1        ${total_count}

