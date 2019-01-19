*** Settings ***
Documentation     This test suite is going to verify whether the alarms can be shelved and un-shelved.
Suite Setup       alarm_setup       n1       ${DEVICES.n1_local_pc.ip_trap}
Suite Teardown    alarm_teardown     n1        ${DEVICES.n1_local_pc.ip_trap}
Library           String
Library           Collections
Library           XML    use_lxml=True
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Alarm_Shelved_Status
    [Documentation]    Test case verifies Alarms can be shelved and un-shelved
    ...    1. Verify alarms can be shelved and show who shelved it, when it was shelved and why it was shelved. manual shelve instance-id X.  
    ...    2. Verify alarms can be un-shelved and show who and when it was un-shelved. (who,when,why - Not Supported)
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2712    @functional    @priority=P2        @user_interface=snmp      @runtime=short

    Log    *** Verifying clear trap is sent when Alarms are shelved and raise trap is sent while un-shelved ***
    : FOR    ${INDEX}    IN RANGE    0    3
    \    Wait Until Keyword Succeeds    30 seconds    5 seconds     SNMP_start_trap    n1_snmp_v2     port=${DEVICES.n1_snmp_v2.redirect}
    \    @{list}       Shelving Active alarms     n1     list     shelved_runningconfig_unsaved
    \    ${instance-id}      Get From List    ${list}    0
    \    @{result}     Wait Until Keyword Succeeds    30 seconds    5 seconds    SNMP_stop_trap     n1_snmp_v2
    \    ${output}      Get From List     ${result}     0
    \    ${count}       Get From List     ${result}     1
    \    Exit For Loop If    ${count} >= 2
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${instance-id}      parameter=shelve
    Wait Until Keyword Succeeds      2 min     10 sec         SNMP_trap_verification_for_running_config_unsaved_alarm     n1_snmp_v2     ${output}     instance-id=${instance-id}      parameter=unshelve

*** Keyword ***
alarm_setup
    [Arguments]    ${device1}      ${local_pc_ip}
    [Documentation]         Configuring SNMP and Triggering Alarm
 
    Log         *** Configuring SNMP on DUT ***
    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device1}       ${local_pc_ip}

    Log         *** Triggering alarms ***
    Wait Until Keyword Succeeds      2 min     10 sec      Triggering any one alarm for severity INFO    ${device1}      user_interface=cli

alarm_teardown
    [Arguments]    ${device1}      ${local_pc_ip}
    [Documentation]         Unconfiguring SNMP and Clearing Alarm

    Log         *** Unconfigure SNMP on DUT ***
    ${local_pc_ip}   Run    /sbin/ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/'
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}    ${local_pc_ip}

    Log         *** Clearing alarm ***
    Wait Until Keyword Succeeds      2 min     10 sec     Clear running-config INFO alarm     ${device1}      user_interface=cli 
