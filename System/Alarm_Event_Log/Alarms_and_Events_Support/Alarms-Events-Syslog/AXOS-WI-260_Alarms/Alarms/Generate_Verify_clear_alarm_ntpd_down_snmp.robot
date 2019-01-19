*** Settings ***
Documentation     This test suite is going to verify whether ntpd down alarm can be triggered and cleared 
Suite Setup       alarm_setup         n1      ${DEVICES.n1_local_pc.ip_trap}
Suite Teardown    alarm_teardown         n1     ${DEVICES.n1_local_pc.ip_trap}     n1_snmp_v2       ${DEVICES.n1_snmp_v2.redirect}
Library           String
Library           Collections
Resource          caferobot/cafebase.robot
Resource          base.robot
Force Tags


*** Test Cases ***

Generate_Verify_clear_alarm_ntpd_down
    [Documentation]    Test case verifies ntpd down alarm is triggered and cleared, maintained in historical alarms
    ...    1. Generate ntpd down alarm
    ...    2. Verify alarm is stored in active and history table
    ...    3. Clear the alarm
    ...    4. Verify the ntpd down alarm is cleared 
    ...    5. Retrieve historial alarms by show alarm history and make sure you see both above events logged
    ...    6. Make sure these alarms are not there in standing alarms table
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He    @author=ssekar   @tcid=AXOS_E72_PARENT-TC-2820     @functional    @priority=P3        @user_interface=snmp

    Log     ******** Verifying ntpd down alarm are triggered and cleared, SNMP traps are received respectively ***********
    : FOR    ${INDEX}    IN RANGE    0    1
    \    ${result}    Wait Until Keyword Succeeds      30 sec     10 sec     Run Keyword And Return Status     Verifying ntpd down alarm    n1_snmp_v2    
    \    ...       ${DEVICES.n1_snmp_v2.redirect}    n1     n1_sh    n1_local_pc      ${DEVICES.n1_local_pc.ip}      ${DEVICES.n1_local_pc.password}
    \    Exit For Loop If    '${result}' == 'True'

    Run Keyword If   '${result}' == 'False'      Fail     msg="Test case failed"

*** Keyword ***
alarm_setup
    [Arguments]            ${device}       ${local_pc_ip} 
    [Documentation]        Clearing Alarm history and configuring SNMP

    Wait Until Keyword Succeeds      2 min     10 sec      Clearing alarm history logs       ${device}

    Log      *** Removing existing SNMP configuration ***
    Wait Until Keyword Succeeds    30 sec     10 sec        Deleting SNMP     ${device}    ${local_pc_ip}

    Log         *** Configuring SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Configuring_SNMP_on_DUT        ${device}       ${local_pc_ip}


alarm_teardown
    [Arguments]      ${device1}    ${local_pc_ip}     ${snmpv2}    ${snmp_port}
    [Documentation]        Unconfiguring SNMP

    Log       *** Making sure SNMP trap is stopped ***
    Wait Until Keyword Succeeds      30 sec     10 sec       Verifying SNMP trap is not running        ${snmpv2}      ${snmp_port}

    Log         *** Unconfigure SNMP on DUT ***
    Wait Until Keyword Succeeds      2 min     10 sec      Unconfiguring_SNMP_on_DUT       ${device1}        ${local_pc_ip}
