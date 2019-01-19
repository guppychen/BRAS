*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_port-rmon-session-tca_Cli
    [Documentation]    Testcase to verify that alarm is generated when the pon port rmon-session threshold exceeds.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-332   @user=root   @user=root   @user=root    @globalid=2226253    @priority=P1    @user_interface=Cli
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost pon-rmon-session-tca MAJOR
    Cli    n1_session2    cli
    ${events}=    command    n1_session2    show event
    Should contain    ${events}    pon-rmon-session-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_port-rmon-session-tca_Cli    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_port-rmon-session-tca_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    exit
    Command    ${DUT}    dcli evtmgrd evtpost pon-rmon-session-tca CLEAR
    Disconnect    ${DUT}
