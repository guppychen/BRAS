*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4     @jira=AT-4212
Resource          base.robot

*** Test Cases ***
Management_Interfaces-Faults-Event-Download Failed Event_Cli
    [Documentation]    Testcase to verify the events are generated when the download of the image fails.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-322    @globalid=2226243    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    #upgrade the image from CLI
    command    n1_session1    upgrade activate filename ${bamboo.eoluswrong}
    #Wait till state of the Upgrade changes to "Download Failed"
    : FOR    ${i}    IN RANGE    500
    \    ${upgrade}=    command    n1_session1    show upgrade status
    \    #get the status of the image upgrade
    \    ${line}=    Get Lines Containing String    ${upgrade}    state
    \    ${string}=    String.Fetch From Right    ${line}    ${SPACE}"
    \    Exit For Loop If    '${string}' == 'Download failed"'
    \    should not contain    ${string}    Installation in progress
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Failed Event
    [Teardown]    Teardown Management_Interfaces-Faults-Event-Download Failed Event_Cli    n1_session1

*** Keywords ***
Teardown Management_Interfaces-Faults-Event-Download Failed Event_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
