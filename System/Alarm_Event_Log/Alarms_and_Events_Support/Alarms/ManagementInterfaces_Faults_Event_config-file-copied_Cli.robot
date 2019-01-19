*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_config-file-copied_Cli
    [Documentation]    Testcase to verify the events are generated when the config file is copied.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-292   @user=root    @globalid=2226213    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    Command    n1_session1    accept running-config

    ${copy-status}=    Command    n1_session1    copy config from running-config to config.txt
    Should contain    ${copy-status}    Copy completed.
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Configuration file was copied
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_config-file-copied_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_config-file-copied_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
