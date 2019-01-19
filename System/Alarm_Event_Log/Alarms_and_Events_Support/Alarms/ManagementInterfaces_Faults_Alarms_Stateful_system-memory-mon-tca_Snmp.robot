*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_Snmp
    [Documentation]    Testcase to verify that alarm is generated when the usage of system memory increases.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-227   @user=root   @user=root    @globalid=2226136    @priority=P1    @user_interface=Snmp
    Cli    n1_session2    cli
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost memory-tca MAJOR
    #Stop the SNMP trap host.
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    memory-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_Snmp    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    command    ${DUT}    dcli evtmgrd evtpost memory-tca CLEAR
    Disconnect    ${DUT}
