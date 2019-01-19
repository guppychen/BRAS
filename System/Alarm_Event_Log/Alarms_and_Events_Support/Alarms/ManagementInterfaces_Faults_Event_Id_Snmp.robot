*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags     @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Id_Snmp
    [Documentation]    To verify if the event-id matches it's definition.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-337    @globalid=2226259    @priority=P1    @user_interface=Snmp
    cli    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    Disconnect    n1_session1
    cli    n1_session1    show version
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    ${events}=    Cli    n1_session1    show event detail
    Should contain    ${events}    101
    #Verify the scenario from CLI
    ${definition}=    cli    n1_session1    show event definition subscope id 101
    ${description}=    String.Get Lines Containing String    ${definition}    description
    ${description}=    Remove string    ${description}    ${SPACE}${SPACE}${SPACE}${SPACE}description${SPACE}
    ${details}=    String.Get Lines Containing String    ${definition}    details
    ${details}=    Remove string    ${details}    ${SPACE}${SPACE}${SPACE}${SPACE}details${SPACE}
    ${name}=    String.Get Lines Containing String    ${definition}    ${SPACE}name
    ${name}=    Remove string    ${name}    ${SPACE}${SPACE}${SPACE}${SPACE}name${SPACE}
    Should contain    ${snmp_trap}    ${description}
    Should contain    ${snmp_trap}    ${details}
    Should contain    ${snmp_trap}    ${name}
    Cli    n1_session1    clear active event
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Id_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Id_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
