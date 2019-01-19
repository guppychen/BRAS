*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4             @jira=AT-4212
Resource          base.robot

*** Test Cases ***
ManagementInterfaces-Faults-Event-reboot to finish activation_Cli
    [Documentation]    Testcase to verify the events are generated when the image is succesfully activated.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-327    @globalid=2226248    @priority=P1    @user_interface=Cli
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
    Should contain    ${events}    Download Requested Event
    Should contain    ${events}    Download Started Event
    Should contain    ${events}    Download Finished Event
    Should contain    ${events}    Verification Started Event
    Should contain    ${events}    Verification Finished Event
    Should contain    ${events}    Installation Started Event
    Should contain    ${events}    Installation Finished Event
    Should contain    ${events}    Reload Required To Finish Activation Event
    [Teardown]    Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces-Faults-Event-reboot to finish activation_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    upgrade cancel    ${DUT}
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
