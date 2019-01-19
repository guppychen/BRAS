*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4   @jira=AT-4212
Resource          base.robot

*** Test Cases ***
Management_Interfaces-Faults-Event-Verification_failed_event_cli
    [Documentation]    Testcase to verify the events are generated when the verification of image fails.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-319    @globalid=2226240    @priority=P1    @user_interface=CLI
    Command    n1_session1    clear active event
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
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Finished Event
    Should contain    ${events}    Verification Started Event
    Should contain    ${events}    Verification Failed Event
    [Teardown]    Teardown Management_Interfaces-Faults-Event-Verification_failed_event_cli    n1_session1

*** Keywords ***
Teardown Management_Interfaces-Faults-Event-Verification_failed_event_cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade_cancel    ${DUT}
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
