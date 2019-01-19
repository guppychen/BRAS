*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4         @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces-Faults-Event-reboot to finish activation_Snmp
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-327    @globalid=2226248    @priority=P1    @user_interface=Snmp
    Command    n1_session1    clear active event
    #configure the SNMP v2
    SNMP_v2_setup    n1_session2
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
    \    Exit For Loop If    '${string}' == 'Reload required to finish activation"'
    #Stop the SNMP trap host.
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
    [Teardown]    Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade cancel    ${DUT}
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
