*** Settings ***
Documentation     This test suite is going to verify whether the alarm service_affecting is displayed correctly in various alarms.
Suite Setup       Alarms_and_SNMP_setup    n1    n1_sh    local_pc_ip=${DEVICES.n1_local_pc.ip_trap}    local_pc_password=${DEVICES.n1_local_pc.password}
Suite Teardown    Alarms_and_SNMP_teardown    n1    n1_sh    local_pc_ip=${DEVICES.n1_local_pc.ip_trap}    local_pc_password=${DEVICES.n1_local_pc.password}
Force Tags
Library           String
Library           Collections
Resource          base.robot

*** Test Cases ***
Alarm_Service_Affecting
    [Documentation]    Test case verifies alarm service_affecting is displayed correctly in various alarms.
    ...    1.Verify the field is correct in the alarm definition. show alarm definition (Not Applicable)
    ...    2.Verify the field is correct in the active alarm. show alarm active (Not Applicable)
    ...    3.Verify the field is correct in the alarm history. show alarm history (Not Applicable)
    ...    4.Verify the field is correct in the suppressed alarm. show alarm suppressed
    ...    5.Verify the field is correct in the shelved alarm. show alarm shelved
    ...    6.Verify the field is correct in the archive alarm. show alarm archive (Not Applicable)
    ...    7.Verify the field is correct in the acknowledged alarm. show alarm acknowledged (Not Applicable)
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-291   @user=root   @jira=EXA-13147   @functional    @priority=P2    @user_interface=snmp    @runtime=short
    #Log    *** Verifying Alarm name is displayed correctly while suppressing (will be included in 3.1.0) ***
    #Run Keyword And Continue On Failure    Suppressing Active alarms    n1
    #Run Keyword And Continue On Failure    Verify Suppressing Alarms    n1    service_affect    suppressed_alarm_loss_of_signal
    #Run Keyword And Continue On Failure    Verify Suppressing Alarms    n1    service_affect    suppressed_alarm_rmon_session
    #Run Keyword And Continue On Failure    Unsuppressing Active alarms    n1

    Log    *** Getting instance-id for Triggered Alarms ***
    ${run_instance_id}    Getting instance-id from Triggered alarms    n1    running_config_unsaved
    ${ntp_instance_id}    Getting instance-id from Triggered alarms    n1    ntp_prov
    ${app_instance_id}    Getting instance-id from Triggered alarms    n1    app_sus

    : FOR    ${INDEX}    IN RANGE    0    5
    \    Log    *** Starting SNMP trap, shelving, and un-shelving NTP-prov alarm, and verifying Trap is received and the alarm service-affect after stopping it ***
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1    parameter=service_affect
    \    ...    command_execution=shelved_ntp_prov
    \    Log    *** Stopping SNMP trap and verifying trap is received in local PC when alarm is shelved and un-shelved ***
    \    @{list}    Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap    n1_snmp_v2
    \    ${result}    Get From List    ${list}    0
    \    ${count}    Get From List    ${list}    1
    \    Exit For Loop If    ${count} >= 2
    Wait Until Keyword Succeeds    2 min    10 sec    SNMP_trap_verification_for_NTP_alarm    n1_snmp_v2    ${result}    instance-id=${ntp_instance_id}
    ...    parameter=service_affect

    : FOR    ${INDEX}    IN RANGE    0    5
    \    Log    *** Starting SNMP trap, shelving, and un-shelving application suspended alarm, and verifying Trap is received and the Alarm service-affect after stopping it ***
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds    Shelving Active alarms    n1    parameter=service_affect
    \    ...    command_execution=shelved_app_sus
    \    @{list}    Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap    n1_snmp_v2
    \    ${result}    Get From List    ${list}    0
    \    ${count}    Get From List    ${list}    1
    \    Exit For Loop If    ${count} >= 2
    Log    *** verifying trap is received in local PC when alarm is shelved and un-shelved ***
    Run Keyword And Continue On Failure    SNMP_trap_verification_for_application_suspended_alarm    n1_snmp_v2    ${result}    instance-id=${app_instance_id}    parameter=service_affect
