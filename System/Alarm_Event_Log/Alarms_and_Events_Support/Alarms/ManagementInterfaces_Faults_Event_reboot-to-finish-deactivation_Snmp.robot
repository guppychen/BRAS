*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags      @eut=NGPON2-4          @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reboot-to-finish-deactivation_Snmp
    [Documentation]    Testcase to verify the events are generated when the deactivation of the patch is successfull..
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-328    @globalid=2226249    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    command    n1_session1    upgrade activate filename ${bamboo.patch}
    #Wait till state of the Upgrade changes to "Activated"
    : FOR    ${i}    IN RANGE    500
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #check if the patch is already installed
    \    ${reason}=    Get Lines Containing String    ${upgrade}    install-error
    \    ${reason}=    String.Fetch From Right    ${reason}    ${SPACE}"
    \    Exit For Loop If    '${reason}' == 'Cannot install patch. Same patch has already been installed."'
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From right    ${line}    ${SPACE}
    \    Log    ${string}
    \    Exit For Loop If    '${string}' == 'Activated'
    #deactivate the patch installed
    command    n1_session1    upgrade deactivate
    : FOR    ${i}    IN RANGE    50
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Exit For Loop If    '${string}' == 'Reload required to finish deactivation"'
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    Reload Required To Finish Deactivation Event
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reboot-to-finish-deactivation_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reboot-to-finish-deactivation_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    ${DUT}
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
