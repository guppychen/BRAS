*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4           @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_activate_aborted_Snmp
    [Documentation]    Testcase to verify the events are generated when the activation of the image is aborted.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-329    @globalid=2226250    @priority=P1    @user_interface=Snmp
    Cli    n1_session1    cli
    Command    n1_session1    clear active event
    Log    ***Create SNMP v2 community and trap host***
    SNMP_v2_setup    n1_session1
    Log    ***Starting the SNMP trap***
    #Start the SNMP trap host
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #upgrade the image using CLI
    command    n1_session1    upgrade activate filename ${bamboo.eolus}
    #Wait till state of the Upgrade changes to "Reload required to finish activation"
    : FOR    ${i}    IN RANGE    5000
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Run keyword If    '${string}' == 'Reload required to finish activation"'    upgrade_cancel    n1_session1
    \    Exit for loop if    '${string}' == 'Downloaded image was installed, then canceled by user. Next boot image is same as current."'
    Log    ***Stoping the SNMP trap***
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_trap}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_trap}
    ${snmp_trap}=    Convert to string    ${snmp_trap}
    Should contain    ${snmp_trap}    Download Requested Event
    Should contain    ${snmp_trap}    Download Started Event
    Should contain    ${snmp_trap}    Download Finished Event
    Should contain    ${snmp_trap}    Verification Started Event
    Should contain    ${snmp_trap}    Verification Finished Event
    Should contain    ${snmp_trap}    Installation Started Event
    Should contain    ${snmp_trap}    Installation Finished Event
    Should contain    ${snmp_trap}    Reload Required To Finish Activation Event
    Should contain    ${snmp_trap}    Activation Aborted Event
    command    n1_session1    upgrade cancel
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_activate_aborted_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_activate_aborted_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    ${DUT}
    Command    ${DUT}    clear active event
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Disconnect    ${DUT}
