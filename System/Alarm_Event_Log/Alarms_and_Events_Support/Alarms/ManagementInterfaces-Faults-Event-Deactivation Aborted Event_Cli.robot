*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4     @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Cli
    [Documentation]    Testcase to verify the events when the deactivation is aborted.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-326    @globalid=2226247    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    #upgrade the image using the CLI
    command    n1_session1    upgrade activate filename ${bamboo.patch}
    #Wait till state of the Upgrade changes to "Activated"
    : FOR    ${i}    IN RANGE    1000
     \   sleep   5s    add check interval as 5s
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
    \    Run keyword If    '${string}' == 'Reload required to finish deactivation"'    upgrade_cancel    n1_session1
    \    Exit For Loop If    '${string}' == 'Reload required to finish deactivation"'
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Reload Required To Finish Deactivation Event
    Should contain    ${events}    Deactivation Aborted Event
    [Teardown]    Teardown ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces-Faults-Event-Deactivation Aborted Event_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
