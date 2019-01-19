*** Settings ***
Documentation     This test suite is going to verify whether the alarms from category PORT can be triggered and cleared 
Suite Setup       alarm_setup       n1     ${DEVICES.n1_local_pc.ip_trap}     n1_sh
Suite Teardown    alarm_teardown    n1     ${DEVICES.n1_local_pc.ip_trap}
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Active_Category_Port
    [Documentation]    Test case verifies alarms from category PORT can be triggered and cleared
    ...    (Alarms : module-fault, improper-removal, unsupported-equipment, dhcp-server-detected) loss-of-signal : This alarm is skipped since it is already verified on
    ...    test case  RLT-TC-1101
    ...    1. Perform actions to trigger the alarms above.   
    ...    2. Look at the details of the active alarms from the CLI. All information in the alarm is correct and matches the alarm definition.   
    ...    3. Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.  
    ...    4. Trap should be sent to the trap host configured. PC (trap host) should receive the trap.  
    ...    5. Clear the condition used to trigger the alarms above.   
    ...    6. Alarm should clear and be shown in the alarm history. Alarm is no longer in active, and shows in alarm History.  
    ...    7. Verify the Netconf notification is sent to the server. Notification trap is sent to clear the alarm.  
    ...    8. Trap should be sent to the trap host configured. PC (trap host) should receive the clear trap. 
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2824   @user=root     @functional    @priority=P1        @user_interface=snmp

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      2 min     10 sec        SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}

    Log    *** Verifying alarms from category PORT can be triggered and cleared ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     n1      n1_sh     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      n1      n1_sh     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm using dcli     n1      n1_sh     unsupported-equipment
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm using dcli      n1      n1_sh     unsupported-equipment
#   comment the dhcp server as will make the device disconnected if craft port dhcp enable
#    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for dhcp server detected     n1
#    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for dhcp server detected     n1

    Wait Until Keyword Succeeds      2 min     10 sec      Triggering alarm for improper-removal      n1      n1_sh  
    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm for improper-removal      n1      n1_sh
 
    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    ${output}      Get From List     ${result}     0
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    improper-removal
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    module-fault
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    unsupported-equipment
 #   Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    dhcp-server-detected

*** Keyword ***
alarm_setup
    [Arguments]        ${device1}    ${local_pc_ip}     ${linux}
    [Documentation]         SNMP configuration

    Log         *** Configuring SNMP on DUT ***
     ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device1}       ${local_pc_ip}

    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm for dhcp server detected    ${device1}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm for improper-removal       ${device1}      ${linux}
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm using dcli      ${device1}      ${linux}     module-fault
    Wait Until Keyword Succeeds      2 min     10 sec     Clearing alarm using dcli      ${device1}      ${linux}     unsupported-equipment

alarm_teardown
    [Arguments]    ${device1}    ${local_pc_ip}
    [Documentation]         Unconfigure SNMP
  
    Log         *** Unconfigure SNMP on DUT ***
    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}    ${local_pc_ip}
