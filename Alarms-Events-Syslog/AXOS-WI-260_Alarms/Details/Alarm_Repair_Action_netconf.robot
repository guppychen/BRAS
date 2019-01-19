*** Settings ***
Documentation     This test suite is going to verify whether the alarm repair-action is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

*** Test Cases ***

Alarm_Repair_Action
    [Documentation]    Test case verifies alarm repair-action is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition
    ...                2.Verify the field is correct in the active alarm. show alarm active
    ...                3.Verify the field is correct in the alarm history. show alarm history
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...                6.Verify the field is correct in the archive alarm. show alarm archive
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2834      @functional    @priority=P2      @user_interface=netconf      @runtime=long

    Log    ******* Verifying Alarm repair-action is displayed correctly in Active alarms ********
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      active_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      active_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      active_alarm_rmon_session

    Log    *** Verifying Alarm repair-action is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      definition_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      definition_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      definition_alarm_rmon_session

    Log    *** Verifying Alarm repair-action is displayed correctly in Alarm history ***
    Run Keyword And Continue On Failure          Alarms_verification_using_netconf        n1_netconf       repair_action      history_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      history_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      history_alarm_rmon_session

    Log    *** Verifying Alarm repair-action is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure     Suppressing Active alarms using netconf      n1_netconf
    #Run Keyword And Continue On Failure      Alarms_verification_using_netconf        n1_netconf       repair_action      suppress_alarm_running_config_unsaved
    #Run Keyword And Continue On Failure      Alarms_verification_using_netconf        n1_netconf       repair_action      suppress_alarm_rmon_session
    #Run Keyword And Continue On Failure       Unsuppressing Active alarms using netconf    n1_netconf

    Log    *** Verifying Alarm repair-action is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf     n1_netconf       repair_action

    Log    *** Verifying Alarm repair-action is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       repair_action

    Log    *** Verifying Alarm repair-action is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf     n1_netconf      n1_sh
    Run Keyword And Continue On Failure        Alarms_verification_using_netconf        n1_netconf       repair_action      archive_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action     archive_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       repair_action      archive_alarm_rmon_session

