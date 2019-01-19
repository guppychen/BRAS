*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Snmp
    [Documentation]    Testcase to verify the if the events are generated when time is changed manually. Since we are generating the alarm by enabling the admin-state of the PON port, atleast one PON port must be in disabled state with no connection.
    [Tags]  dual_card_not_support   dual_card_not_support  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-218   @user=root   @user=root    @globalid=2226127    @priority=P1    @user_interface=Snmp
    command    n1_session2    cli
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault Major    timeout_exception=0    prompt=#
    command    n1_session2    cli
    #Stop the SNMP trap host.
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should Contain    ${snmp_trap}    module-fault
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Snmp    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session2
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault CLEAR
    Disconnect    ${DUT}
