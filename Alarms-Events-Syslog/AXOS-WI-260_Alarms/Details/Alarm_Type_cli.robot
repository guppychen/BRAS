*** Settings ***
Documentation     This test suite is going to verify whether the alarm type is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms     n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Suite Teardown     Clearing_Alarms       n1        n1_sh      ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar    @reload

*** Test Cases ***

Alarm_Type
    [Documentation]    Test case verifies alarm type is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition
    ...                2.Verify the field is correct in the active alarm. show alarm active
    ...                3.Verify the field is correct in the alarm history. show alarm history
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...                6.Verify the field is correct in the archive alarm. show alarm archive
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2831    @functional    @priority=P2      @user_interface=CLI      @runtime=long

    Log    *** Verifying Alarm type is displayed correctly in Active alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      active_alarm_loss_of_signal     alarm=signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      alarm=ntp_prov_act     type=active
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      active_alarm_rmon_session

    Log    *** Verifying Alarm type is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      definition_alarm_loss_of_signal     alarm=signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      alarm=ntp_prov_act     type=definition
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      definition_alarm_rmon_session

    Log    *** Verifying Alarm type is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      history_alarm_loss_of_signal       alarm=signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      alarm=ntp_prov_his     type=history
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      history_alarm_rmon_session

    Log    *** Verifying Alarm type is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure      Suppressing Active alarms    n1
    #Run Keyword And Continue On Failure      Verify Suppressing Alarms        n1       alarm_type      suppressed_alarm_loss_of_signal
    #Run Keyword And Continue On Failure     Verify Suppressing Alarms        n1       alarm_type      suppressed_alarm_rmon_session
    #Run Keyword And Continue On Failure      Unsuppressing Active alarms    n1

    Log    *** Verifying Alarm type is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1       alarm_type      shelved_runningconfig_unsaved    

    Log    *** Verifying Alarm type is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1       alarm_type

    Log    *** Verifying Alarm type is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm      n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload System     n1
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      archiving_alarm_loss_of_signal     alarm=signal_loss
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      alarm=ntp_prov_his     type=archive
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Generic Alarms        n1       alarm_type      archiving_alarm_rmon_session


