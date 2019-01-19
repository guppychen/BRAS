*** Settings ***
Documentation     This test suite is going to verify whether Active alarms can be filtered using subscope category.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support  @author=ssekar

*** Test Cases ***

Alarms_Active_Filter_by_subscope_category
    [Documentation]    Test case verifies Active alarms filtered by subscope category.
    ...                1. Use show alarms filter command and filter by subscope category.  Verify alarms are displayed for various categories. show alarm active subscope category
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2845      @functional    @priority=P2      @user_interface=CLI

    Log         *** Getting Active alarms total count ***
    ${total_count}    Getting Active alarms total count    n1

    Log    *** Verifying Active alarms gets filtered using subscope category ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verifying Active Alarm subscope gets filtered using category      n1        ${total_count}

