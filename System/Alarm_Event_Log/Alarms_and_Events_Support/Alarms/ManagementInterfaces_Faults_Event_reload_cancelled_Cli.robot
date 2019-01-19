*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_cancelled_Cli
    [Documentation]    Testcase to verify the if the events are generated when reload in cancelled.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-301    @globalid=2226222    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    #schdule the reload for the device from the CLI.
    Command    n1_session1    reload in 100    timeout_exception=0
    command    n1_session1    y    timeout_exception=0    prompt=#
    ${events}=    command    n1_session1    show event
    #Cancel the reload
    command    n1_session1    stop reload
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    A scheduled reload has been cancelled
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_cancelled_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_cancelled_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    stop reload
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
