*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_system_Snmp
    [Documentation]    Testcase to verify the if the event is generated when the system reloads. This testcase will reset the device.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-303    @globalid=2226224    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #schdule the reload for the device from the CLI.
    Command    n1_session1    reload    timeout_exception=0
    command    n1_session1    y    timeout_exception=0    prompt=#
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    reload-system
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_system_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_system_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #wait for the system to boot.The system takes around 5 seconds to reboot after we issue "reload" command. Hence using the sleep command.
    sleep    5
    Wait Until Keyword Succeeds    24x    20 seconds    Check Status    n1_session1
    Command    ${DUT}    clear active event
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    ${DUT}
    Disconnect    ${DUT}

Check Status
    [Arguments]    ${DUT}
    [Documentation]    To check the version of the DUT
    [Tags]    @author=Shesha Chandra
    command    n1_session1    cli
    command    n1_session1    Show version
