*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support   @author=Doris He    @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_port-rmon-session-tca_Netconf
    [Documentation]    Testcase to verify that alarm is generated when the pon port rmon-session threshold exceeds.
    [Tags]  dual_card_not_support  @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-332   @user=root   @user=root   @user=root    @globalid=2226253    @priority=P1    @user_interface=Netconf
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost pon-rmon-session-tca MAJOR
    Cli    n1_session2    cli
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${message}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    Should contain    ${message.xml}    pon-rmon-session-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_port-rmon-session-tca_Netconf    n1_session2    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_port-rmon-session-tca_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    exit
    Command    ${DUT}    dcli evtmgrd evtpost pon-rmon-session-tca CLEAR
    Disconnect    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
