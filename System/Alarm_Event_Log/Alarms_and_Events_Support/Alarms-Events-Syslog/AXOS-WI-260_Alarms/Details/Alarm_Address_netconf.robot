*** Settings ***
Documentation     This test suite is going to verify whether the alarm address is displayed correctly in various alarms.
Suite Setup       Triggering_Alarms_netconf     n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Suite Teardown    Clearing_Alarms_netconf       n1_netconf    n1_sh       ${DEVICES.n1.ports.p1.port}
Resource          base.robot
Force Tags

*** Test Cases ***

Alarm_Address
    [Documentation]    Test case verifies alarm address is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition
    ...                2.Verify the field is correct in the active alarm. show alarm active
    ...                3.Verify the field is correct in the alarm history. show alarm history
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...                6.Verify the field is correct in the archive alarm. show alarm archive
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged
    [Tags]        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2838   @user=root      @functional    @priority=P2      @user_interface=netconf      @runtime=long

    Log    ******* Verifying Alarm address is displayed correctly in Active alarms ********
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      active_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      active_alarm_ntp_prov

    Log    *** Verifying Alarm address is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      definition_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      definition_alarm_ntp_prov

    Log    *** Verifying Alarm address is displayed correctly in Alarm history ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      history_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      history_alarm_ntp_prov

    Log    *** Verifying Alarm address is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure       Suppressing Active alarms using netconf    n1_netconf
    #Run Keyword And Continue On Failure       Alarms_verification_using_netconf      n1_netconf       address      suppress_alarm_running_config_unsaved
    #Run Keyword And Continue On Failure      Alarms_verification_using_netconf      n1_netconf       address      suppress_alarm_rmon_session
    #Run Keyword And Continue On Failure       Unsuppressing Active alarms using netconf    n1_netconf

    Log    *** Verifying Alarm address is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf       n1_netconf      address

    Log    *** Verifying Alarm address is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       address

    Log    *** Verifying Alarm address is displayed correctly in Archived alarms ***
    Run Keyword     Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf     n1_netconf      n1_sh
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      archive_alarm_running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf      n1_netconf       address      archive_alarm_ntp_prov



