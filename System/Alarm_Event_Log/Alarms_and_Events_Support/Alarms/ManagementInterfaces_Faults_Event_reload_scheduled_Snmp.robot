*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_scheduled_Snmp
    [Documentation]    Testcase to verify the if the events are generated when reload in scheduled.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-302    @globalid=2226223    @priority=P1    @user_interface=Snmp
    Cli    n1_session1    cli
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    log   schdule the reload for the device from the CLI.
    ${reload_str}    release_cmd_adapter   n1_session1    ${prov_reload_cmd}
    cli    n1_session1    reload ${reload_str} in 100    prompt=Proceed with reload\\? \\[y/N\\]
    cli    n1_session1    y    timeout=60
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    A reload has been scheduled
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    ${DUT}
    command    ${DUT}    stop reload
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
