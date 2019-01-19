*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_high-loss-tca_Netconf
    [Documentation]    Testcase to verify that alarm is generated when the Loss ratio threshold exceeds.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-331   @user=root   @user=root   @user=root    @globalid=2226252    @priority=P1    @user_interface=Netconf
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost high-loss-tca MAJOR
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${message}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    Should contain    ${message.xml}    high-loss-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_high-loss-tca_Netconf    n1_session2    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_high-loss-tca_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    dcli evtmgrd evtpost high-loss-tca CLEAR
    Disconnect    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
