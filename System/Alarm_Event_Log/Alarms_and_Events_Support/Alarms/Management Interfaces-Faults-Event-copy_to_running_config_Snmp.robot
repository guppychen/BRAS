*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Management Interfaces-Faults-Event-copy_to_running_config_Snmp
    [Documentation]    Testcase to verify the if the events are generated when config file is copied to running-config.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-291   @user=root    @globalid=2226212    @priority=P1    @user_interface=SNMP
    Command    n1_session1    clear active event
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    ${copy-status}=    Command    n1_session1    copy running-config startup-config
    Should contain    ${copy-status}    Copy completed.
    ${copy-status}=    Command    n1_session1    copy startup-config running-config
    Should contain    ${copy-status}    Copy completed.
    #Stop the SNMP trap host.
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    Copy into running configuration was done
    [Teardown]    Teardown Management Interfaces-Faults-Event-copy_to_running_config_Snmp    n1_session1

*** Keywords ***
Teardown Management Interfaces-Faults-Event-copy_to_running_config_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    ${copy-status}=    Command    n1_session1    copy running-config startup-config
    Should contain    ${copy-status}    Copy completed.
    Disconnect    ${DUT}
    sleep  5s