*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_system-temp-mon-tca_cli
    [Documentation]    Testcase to verify that alarm is generated when the system temparature exceeds threshold.
    [Tags]  dual_card_not_support  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-224   @user=root    @globalid=2226133    @priority=P1    @user_interface=Cli
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost switch-temperature-tca MAJOR
    Cli    n1_session2    cli
    ${alarms}=    command    n1_session2    show alarm active sub id 3901
    Should contain    ${alarms}    switch-temperature-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-temp-mon-tca_cli    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-temp-mon-tca_cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    exit
    command    ${DUT}    dcli evtmgrd evtpost switch-temperature-tca CLEAR
    Disconnect    ${DUT}
