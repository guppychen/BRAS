*** Settings ***
Documentation     This test suite is going to verify whether the active alarms can be shelved and un-shelved, collecting logs in syslog server as well as SNMP trap
Suite Setup       alarm_setup   n1_local_pc     n1     ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}   ${DEVICES.n1_local_pc.ip_trap}
Suite Teardown    alarm_teardown    n1     ${DEVICES.n1_local_pc.ip}       ${DEVICES.n1_local_pc.ip_trap}
Library           String
Library           Collections
Library           OperatingSystem
Resource          base.robot
Force Tags

*** Test Cases ***

Browsing_shelved_alarm_instances
    [Documentation]    Test case verifies whether the active alarms can be shelved and un-shelved, collecting logs in syslog server as well as SNMP trap 
    ...     1. Make a configuration change to trigger an active alarm for unsaved changes.  Any alarm can be used. 
    ...     2. Show the active alarms. Alarm is shown as active. show alarm active 
    ...     3. Manually shelve an alarm. Alarm is shelved. manual shelve instance-id x.y 
    ...     4. CLI and Netconf: Use the show alarm shelved to verify shelved alarms. Timestamp should be the time the alarm was shelved. Alarm shows as shelved. show alarm shelved 
    ...     5. SNMP: Verify clear trap is sent for the alarm. Timestamp should be the time the alarm was shelved.   
    ...     6. Syslog: Verify clear notification is sent to logging host. Timestamp should be the time the alarm was shelved.   
    ...     7. Clear the alarm condition and verify it no longer shows as a shelved alarm. Alarm is cleared and trap and notifications are sent. copy run start 
    ...     8. Make another configuration change to trigger alarm again. Verify it is showing in the active alarm and trap/notifications are sent. show alarm active 
    ...     9. Unshelve the alarm and verify it goes back to the active alarm log. Alarm is shown as active and trap/notifications are sent.. manual un-shelve instance-id x.y 
    [Tags]       @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2861   @user=root    @functional    @priority=P2       @user_interface=cli,syslog,snmp

  
    Log    *** Getting instance-id for Triggered Alarms ***
    ${run_instance_id}       Getting instance-id from Triggered alarms       n1        running_config_unsaved
 
    Log    *** Verifying alarm is shelved and clear trap is sent for the Alarm in SNMP and Syslog ***
    : FOR    ${INDEX}    IN RANGE    0    3
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    \    @{list}       Shelving Active alarms     n1     list     shelved_runningconfig_unsaved     un-shelve=False
    \    ${instance-id}      Get From List    ${list}    0
    \    ${shelved_time}     Get From List    ${list}    1
    \    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    \    ${output}      Get From List     ${result}     0
    \    ${count}       Get From List     ${result}     1
    \    Exit For Loop If    ${count} >= 1 
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${run_instance_id}      parameter=shelve
    Wait Until Keyword Succeeds    60 seconds    5 seconds    Alarm_shelved_unshelved_message_recorded_on_syslog_Server      n1    n1_local_pc    ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}     ${instance-id}    ${shelved_time}
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Restarting syslog server on local pc      n1_local_pc      ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}

    Log     *** Clear the alarm condition and verify it no longer shows as a shelved alarm. Alarm is cleared and trap and notifications are sent ***
    : FOR    ${INDEX}    IN RANGE    0    3
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    \    Clear running-config INFO alarm     n1      user_interface=cli
    \    Verify cleared alarm removed from shelved       n1      ${run_instance_id}
    \    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    \    ${output}      Get From List     ${result}     0
    \    ${count}       Get From List     ${result}     1
    \    Exit For Loop If    ${count} >= 2
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_config-file-copied        n1_snmp_v2       ${output}   
    Wait Until Keyword Succeeds      2 min     10 sec         Alarm_running_config_unsaved_registered_on_syslog_server     n1    n1_local_pc    ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}     parameter=shelved_alarm_clear
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Restarting syslog server on local pc      n1_local_pc      ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}

    Log    *** Make another configuration change to trigger alarm again. Verify it is showing in the active alarm and trap/notifications are sent ***
    : FOR    ${INDEX}    IN RANGE    0    3 
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    \    Wait Until Keyword Succeeds      2 min     10 sec      Triggering any one alarm for severity INFO    n1      user_interface=cli
    \    ${run_instance_id}       Getting instance-id from Triggered alarms       n1        running_config_unsaved
    \    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    \    ${output}      Get From List     ${result}     0
    \    ${count}       Get From List     ${result}     1
    \    Exit For Loop If    ${count} >= 1
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${run_instance_id}      parameter=raise
    Wait Until Keyword Succeeds      2 min     10 sec         Alarm_running_config_unsaved_registered_on_syslog_server      n1    n1_local_pc    ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}     parameter=raise_alarm
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Restarting syslog server on local pc      n1_local_pc      ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}
  
    Log    *** Unshelve the alarm and verify it goes back to the active alarm log. Alarm is shown as active and trap/notifications are sent ***
    : FOR    ${INDEX}    IN RANGE    0    3
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    \    @{list}       Shelving Active alarms     n1     list     shelved_runningconfig_unsaved
    \    ${instance-id}      Get From List    ${list}    0
    \    ${shelved_time}     Get From List    ${list}    1
    \    ${un_shelved_time}     Get From List    ${list}    2
    \    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    \    ${output}      Get From List     ${result}     0
    \    ${count}       Get From List     ${result}     1
    \    Exit For Loop If    ${count} >= 2
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${run_instance_id}      parameter=unshelve
    Wait Until Keyword Succeeds    30 seconds    5 seconds    Alarm_shelved_unshelved_message_recorded_on_syslog_Server      n1    n1_local_pc    ${DEVICES.n1_local_pc.ip}     ${DEVICES.n1_local_pc.password}     ${instance-id}    ${shelved_time}     ${un_shelved_time}
    
*** Keyword ***
alarm_setup
    [Arguments]    ${device_local_pc}    ${device1}    ${syslog_server_ip}     ${user_password}        ${syslog_server_ip_trap}
    [Documentation]         Configure SYSLOG server SNMP and Triggering alarm for INFO severity

    Log        *** Enabling NTP server on DUT ***
#    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec       Enabling NTP server       ${device1}      ${syslog_server_ip}

    Log         *** Configure SYSLOG server on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec       Configure SYSLOG server on DUT           ${device1}     ${syslog_server_ip}

    Wait Until Keyword Succeeds      2 min     10 sec      Syslog_server_configure_on_local_PC     ${device_local_pc}     ${syslog_server_ip}     ${user_password}

    Log         *** Configuring SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device1}        ${syslog_server_ip_trap}

    Log         *** Triggering alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering any one alarm for severity INFO    ${device1}      user_interface=cli

alarm_teardown
    [Arguments]    ${device1}    ${syslog_server_ip}      ${syslog_server_ip_trap}
    [Documentation]        Clearing INFO alarm

    Log         *** Unconfigure SYSLOG server ***
#    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfigure SYSLOG server on DUT           ${device1}     ${syslog_server_ip}

    Log         *** Unconfigure SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}    ${syslog_server_ip_trap}

    Log         *** Clearing alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}      user_interface=cli
    
