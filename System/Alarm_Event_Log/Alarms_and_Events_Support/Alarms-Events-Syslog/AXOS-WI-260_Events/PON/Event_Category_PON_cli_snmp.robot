*** Settings ***
Documentation     This test suite is going to verify whether the following PON events can be triggered.
Suite Setup       alarm_setup       n1     ${DEVICES.n1_local_pc.ip}     n1_sh
Suite Teardown    alarm_teardown    n1     ${DEVICES.n1_local_pc.ip}
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Event_Category_PON
    [Documentation]    Test case verifies whether the following PON events can be triggered
    ...    (Events : ont-arrival, ont-departure, ont-link, ont-unlink)
    ...    1. Open a CLI session to the EUT, open netconf session and subscribe to notifications, configure a trap host, and set up a PC to capture traps.   
    ...    2. Perform actions to trigger the events above.   
    ...    3. Look at the details of the event from the CLI. All information in the event is correct.  
    ...    4. Verify the event is shown on the syslog server. Information from the CLI is available in the syslog message.  
    ...    5. Verify the Netconf notification was sent to the logging host. All information in the alarm is shown in the notification.  
    ...    6. Trap should be sent to the trap host configured. PC (trap host) should receive the trap. 
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=ssekar  @tcid=AXOS_E72_PARENT-TC-2877   @user=root     @functional    @priority=P1        @user_interface=snmp,cli    @tag=skip_for_bug

    Log    *** Starting SNMP trap ***
    Wait Until Keyword Succeeds      2 min     10 sec        SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}

    Log    *** Verifying ONT events can be triggered ***
    #Wait Until Keyword Succeeds      2 min     10 sec      Triggering ont-departure event      n1
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering ont-arrival event      n1      n1_sh
    #Wait Until Keyword Succeeds      2 min     10 sec      Triggering ont-link event      n1
    #Wait Until Keyword Succeeds      2 min     10 sec      Triggering ont-unlink event      n1

    Log     *** Stopping SNMP trap and verifying it ***
    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    ${output}      Get From List     ${result}     0
    #Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    ont-departure
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications_for_events      n1_snmp_v2     ${output}    ont-arrival
    #Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    ont-link
    #Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verifications      n1_snmp_v2     ${output}    ont-unlink

*** Keyword ***
alarm_setup
    [Arguments]        ${device1}    ${local_pc_ip}     ${linux}
    [Documentation]         SNMP configuration

    Log         *** Configuring SNMP on DUT ***
    #${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device1}       ${DEVICES.n1_local_pc.ip_trap}

alarm_teardown
    [Arguments]    ${device1}    ${local_pc_ip}
    [Documentation]         Unconfigure SNMP and clearing ONT events

    Log         *** Unconfigure SNMP on DUT ***
    #${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}    ${DEVICES.n1_local_pc.ip_trap}

