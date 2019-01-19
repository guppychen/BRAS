*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_cli
    [Documentation]    Testcase to verify that alarm is generated when the usage of system memory increases.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-227   @user=root   @user=root    @globalid=2226136    @priority=P1    @user_interface=Cli
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost memory-tca MAJOR
    Cli    n1_session2    cli
    ${events}=    command    n1_session2    show alarm acti sub id 2609
    Should contain    ${events}    memory-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_cli    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    exit
    command    ${DUT}    dcli evtmgrd evtpost memory-tca CLEAR
    Disconnect    ${DUT}
