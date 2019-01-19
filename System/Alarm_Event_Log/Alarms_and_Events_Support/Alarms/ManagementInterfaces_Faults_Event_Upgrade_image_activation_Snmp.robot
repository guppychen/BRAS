*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4       @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Upgrade_image_activation_Snmp
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-317    @globalid=2226238    @priority=P1    @user_interface=Snmp
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
    Should contain    ${snmp_trap}    upgrade-requested
    Should contain    ${snmp_trap}    upgrade-downloading-image
    Should contain    ${snmp_trap}    upgrade-downloaded-image
    Should contain    ${snmp_trap}    upgrade-verifying-image
    Should contain    ${snmp_trap}    upgrade-image-verified
    Should contain    ${snmp_trap}    upgrade-installing-image
    Should contain    ${snmp_trap}    upgrade-installed-image
    Should contain    ${snmp_trap}    upgrade-reload-required-to-act
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Snmp    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Snmp
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade cancel    ${DUT}
    #Remove the SNMP v2
    run keyword and ignore error      SNMP_stop_trap    n1_snmp_v2
    SNMP_v2_teardown    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
