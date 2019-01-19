*** Settings ***
Documentation     This test suite is going to verify whether the alarm probable-cause is displayed correctly in various alarms.
Suite Setup       alarm_setup      n1_sh      n1_netconf       ${DEVICES.n1.ports.p1.port}
Suite Teardown    alarm_teardown      n1_sh      n1_netconf       ${DEVICES.n1.ports.p1.port}
Library           String
Library           Collections
Resource          base.robot
Force Tags        @feature=Alarm_Event_Log   @subfeature=Alarms and Events Support     @author=ssekar

*** Test Cases ***

Alarm_Probable_Cause
    [Documentation]    Test case verifies alarm probable-cause is displayed correctly in various alarms.
    ...                1.Verify the field is correct in the alarm definition. show alarm definition
    ...                2.Verify the field is correct in the active alarm. show alarm active
    ...                3.Verify the field is correct in the alarm history. show alarm history
    ...                4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...                5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...                6.Verify the field is correct in the archive alarm. show alarm archive
    ...                7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged
    [Tags]         @tcid=AXOS_E72_PARENT-TC-2833    @functional    @priority=P2      @user_interface=netconf     @runtime=long

    Log    *** Verifying Alarm probable-cause is displayed correctly in Active alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      active_alarm_application_suspended
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      active_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      active_alarm_rmon_session

    Log    *** Verifying Alarm probable-cause is displayed correctly in Alarm definitions ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      definition_alarm_application_suspended
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      definition_alarm_ntp_prov
    Run Keyword And Continue On Failure        Checking_Alarm_definition_parameters_netconf        n1_netconf       probable-cause
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      definition_alarm_rmon_session

    Log    *** Verifying Alarm probable-cause is displayed correctly in Alarm history ***
    Run Keyword And Continue On Failure          Alarms_verification_using_netconf        n1_netconf       probable_cause      history_alarm_application_suspended
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      history_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      history_alarm_rmon_session

    Log    *** Verifying Alarm probable-cause is displayed correctly while suppressing ***
    #Run Keyword And Continue On Failure      Suppressing Active alarms using netconf      n1_netconf
    #Run Keyword And Continue On Failure      Alarms_verification_using_netconf        n1_netconf       probable_cause      suppress_alarm_application_suspended
    #Run Keyword And Continue On Failure      Alarms_verification_using_netconf        n1_netconf       probable_cause      suppress_alarm_rmon_session
    #Run Keyword And Continue On Failure      Unsuppressing Active alarms using netconf    n1_netconf

    Log    *** Verifying Alarm probable-cause is displayed correctly while shelving ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms using netconf     n1_netconf       probable_cause     shelve_alarm_application_suspended

    Log    *** Verifying Alarm probable-cause is displayed correctly in Acknowledged alarms ***
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged using netconf     n1_netconf       probable_cause    ack_alarm_application_suspended

    Log    *** Verifying Alarm probable-cause is displayed correctly in Archived alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing Archive alarm using netconf      n1_netconf
    Wait Until Keyword Succeeds      2 min     10 sec          Clearing CRITICAL alarm       n1_sh       n1_netconf      user_interface=netconf
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Reload The System using netconf      n1_netconf      n1_sh
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      archive_alarm_application_suspended
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      archive_alarm_ntp_prov
    #Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarms_verification_using_netconf        n1_netconf       probable_cause      archive_alarm_rmon_session

*** Keyword ***
alarm_setup
    [Arguments]        ${device_linux}      ${device_netconf}      ${DEVICES.n1.ports.p1.port}
    [Documentation]    Triggering alarms on basis of severity

    Log    *** Trigerring one CRITICAL alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering CRITICAL alarm      ${device_linux}       ${device_netconf}      user_interface=netconf

    Log    *** Trigerring NTP prov Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Trigerring NTP prov alarm netconf      ${device_netconf}

    Log    *** Trigerring one INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO    ${device_netconf}     ${device_linux}      user_interface=netconf

alarm_teardown
    [Arguments]       ${device_linux}    ${device_netconf}     ${DEVICES.n1.ports.p1.port}
    [Documentation]    Clearing alarms

    Log    *** Clearing the created NTP prov Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing NTP prov alarm netconf     ${device_netconf}

    Log    *** Clearing the created INFO Alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm    ${device_netconf}    ${device_linux}     user_interface=netconf
