*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags         @eut=NGPON2-4         @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Upgrade_image_activation_Cli
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-317    @globalid=2226238    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    #upgrade the image using CLI
    command    n1_session1    upgrade activate filename ${bamboo.eolus}
    #Wait till state of the Upgrade changes to "Reload required to finish activation"
    wait until keyword succeeds    10 min   1 min    check_update_statue  n1_session1
#    : FOR    ${i}    IN RANGE    5000
#    \    ${upgrade}=    command    n1_session1    show upgrade status
#    \    #get the status of the image upgrade
#    \    ${line}=    Get Lines Containing String    ${upgrade}    state
#    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
#    \    Exit For Loop If    '${string}' == 'Reload required to finish activation"'
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    upgrade-requested
    Should contain    ${events}    upgrade-downloading-image
    Should contain    ${events}    upgrade-downloaded-image
    Should contain    ${events}    upgrade-verifying-image
    Should contain    ${events}    upgrade-image-verified
    Should contain    ${events}    upgrade-installing-image
    Should contain    ${events}    upgrade-installed-image
    Should contain    ${events}    upgrade-reload-required-to-act
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Upgrade_image_activation_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade cancel    ${DUT}
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
