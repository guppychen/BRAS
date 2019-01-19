*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_scheduled_Cli
    [Documentation]    Testcase to verify the if the events are generated when reload in scheduled.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-302    @globalid=2226223    @priority=P1    @user_interface=Cli
    Cli    n1_session1    cli
    Command    n1_session1    clear active event
    #schdule the reload for the device from the CLI.
    ${reload_str}    release_cmd_adapter   n1_session1    ${prov_reload_cmd}
    cli    n1_session1    reload ${reload_str} in 100    prompt=Proceed with reload\\? \\[y/N\\]
    cli    n1_session1    y    timeout=60
    ${events}=    command    n1_session1    show event
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    A reload has been scheduled
    command    n1_session1    stop reload
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    stop reload
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
