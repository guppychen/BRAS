*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Snmp
    [Documentation]    Testcase to verify if the alarm is generated when SFP/SFP+/XFP pluggable device has been improperly removed
    [Tags]   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-217    @globalid=2226126    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    # if the admin-state of the pon port is bought up without any connection we can see the improper-removal alarm generated.
    ${pon}=    command    n1_session1    show interface pon status
    #get the details of all the pon port to check which port is disabled
    ${pon}=    String.Get Lines Containing String    ${pon}    interface pon
    ${count}=    get line count    ${pon}
    set suite variable    ${count}    ${count}
    : FOR    ${i}    IN RANGE    3    ${count}
    \    ${status}=    command    n1_session1    show interface pon ${ethernet.ponport}${i} status
    \    command    n1_session1    config
    \    ${port}=    command    n1_session1    interface pon ${ethernet.ponport}${i}
    \    ${status}=    String.Get Lines Containing String    ${status}    admin-state
    \    ${status}=    String.Fetch From Right    ${status}    ${SPACE}
    \    Run Keyword If    '${status}' == 'disable'    command    n1_session1    no shutdown
    \    command    n1_session1    end
#    \    Exit For Loop If    '${status}' == 'disable'
    #Stop the SNMP trap host.
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should Contain    ${snmp_trap}    improper-removal
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Snmp    n1_session1    ${port}

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Statefu_Generate_Verify_clear_alarm_improper-removal_Snmp
    [Arguments]    ${DUT}    ${PORT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    : FOR    ${i}    IN RANGE    1    ${count}
    \    ${port}=    command    n1_session1    interface pon ${ethernet.ponport}${i}
    \    Command    ${DUT}    config
    \    Command    ${DUT}    ${port}
    \    Command    ${DUT}    shutdown
    \    Command    ${DUT}    end
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Disconnect    ${DUT}
