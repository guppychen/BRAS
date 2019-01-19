*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4         @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_activate_aborted_Cli
    [Documentation]    Testcase to verify the events are generated when the activation of the image is aborted.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-329    @globalid=2226250    @priority=P1    @user_interface=Cli
    Cli    n1_session1    cli
    Command    n1_session1    clear active event
    #upgrade the image using CLI
    command    n1_session1    upgrade activate filename ${bamboo.eolus}
    #Wait till state of the Upgrade changes to "Reload required to finish activation"
    : FOR    ${i}    IN RANGE    5000
    \    ${upgrade}=    command    n1_session1    show upgrade status    prompt=reason    timeout=30
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Run keyword If    '${string}' == 'Reload required to finish activation"'    upgrade_cancel    n1_session1
    \    Exit for loop if    '${string}' == 'Downloaded image was installed, then canceled by user. Next boot image is same as current."'
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Finished Event
    Should contain    ${events}    Verification Started Event
    Should contain    ${events}    Verification Finished Event
    Should contain    ${events}    Installation Started Event
    Should contain    ${events}    Installation Finished Event
    Should contain    ${events}    Reload Required To Finish Activation Event
    Should contain    ${events}    Activation Aborted Event
    command    n1_session1    upgrade cancel
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_activate_aborted_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_activate_aborted_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    ${DUT}
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
