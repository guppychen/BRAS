*** Settings ***
Documentation     This test suite is going to verify whether the active alarms can be acknowledged.
Suite Setup       alarm_setup    n1     n1_sh      ${DEVICES.n1_local_pc.ip_trap}
Suite Teardown    alarm_teardown    n1     n1_sh     ${DEVICES.n1_local_pc.ip_trap}
Library           String
Library           Collections
Resource          base.robot
Force Tags

*** Test Cases ***

Alarm_acknowledged_status
    [Documentation]    Test case verifies Active alarms is acknowledgeable
    ...                1. Trigger an alarm and find the alarm instance id. show alarm active.
    ...                2. Manually acknowledge the alarm based on the instance id. manual acknowledge instance-id x.x
    ...                3. Verify acknowledged alarm indicates who acknowledged it, when it was acknowledged and why it was acknowledged (Not Supported)
    ...                4. Verify alarm can be unacknowledged.(Not Supported)
    [Tags]        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2891   @user=root    @functional    @priority=P2       @user_interface=snmp      @runtime=short

    Log         *** Verifying no SNMP clear trap is generated when Alarm is acknowledged ***
    ${run_instance_id}       Getting instance-id from Triggered alarms       n1        running_config_unsaved
    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Verify Alarms Get Acknowledged     n1
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    ${output}      Get From List     ${result}     0
    ${count}       Get From List     ${result}     1
    Wait Until Keyword Succeeds      1 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${run_instance_id}      parameter=ack


*** Keyword ***
alarm_setup
    [Arguments]    ${device1}    ${linux}     ${local_pc_ip}
    [Documentation]         Triggering alarm for INFO severity
    
    Log         *** Configuring SNMP on DUT ***
    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device1}       ${local_pc_ip}

    Log    *** Trigerring one INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec      Clear running-config INFO alarm     ${device1}     ${linux}     cli
    Wait Until Keyword Succeeds      2 min     10 sec     Triggering any one alarm for severity INFO     ${device1}     ${linux}     cli


alarm_teardown
    [Arguments]    ${device1}     ${linux}     ${local_pc_ip}
    [Documentation]        Clearing INFO alarm

    Log         *** Unconfigure SNMP on DUT ***
    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}    ${local_pc_ip}

    Log         *** Clearing INFO alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}     ${linux}     cli
