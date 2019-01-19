*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4     @jira=AT-4212
Resource          base.robot

*** Test Cases ***
Management_Interfaces-Faults-Event-Verification_failed_event_snmp
    [Documentation]    Testcase to verify the events are generated when the verification of image fails.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-319    @globalid=2226240    @priority=P1    @user_interface=SNMP
    #config the snmp v2
    SNMP_v2_setup    n1_session1
    Command    n1_session1    clear active event
    #Start the SNMP traps
    SNMP_start_trap    n1_snmp_v2    port=${DEVICES.n1_snmp_v2.redirect}
    #upgrade the image using the CLI
    command    n1_session1    upgrade activate filename ${bamboo.denali}
    #Wait till state of the Upgrade changes to "Image Verification Failed"
    : FOR    ${i}    IN RANGE    5000
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Exit For Loop If    '${string}' == 'Image verification failed"'
    \    should not contain    ${string}    Installation in progress
    #Stop the SNMP traps
    SNMP_stop_trap    n1_snmp_v2
    ${snmp_traps}    snmp get trap host results    n1_snmp_v2
    Log    ${snmp_traps}
    ${snmp_traps}=    Convert to string    ${snmp_traps}
    Should contain    ${snmp_traps}    Download Requested Event
    Should contain    ${snmp_traps}    Download Started Event
    Should contain    ${snmp_traps}    Download Finished Event
    Should contain    ${snmp_traps}    Verification Started Event
    Should contain    ${snmp_traps}    Verification Failed Event
    [Teardown]    Teardown Management_Interfaces-Faults-Event-Verification_failed_event_snmp    n1_session1

*** Keywords ***
Teardown Management_Interfaces-Faults-Event-Verification_failed_event_snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    ${DUT}
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
