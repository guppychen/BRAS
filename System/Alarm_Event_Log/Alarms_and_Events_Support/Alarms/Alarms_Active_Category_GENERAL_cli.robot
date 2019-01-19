*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Alarms_Active_Category_GENERAL_cli
    [Documentation]    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent. Reset the device to clear all the alarm.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-204   @user=root    @globalid=2226113    @priority=P1    @user_interface=Cli
    command    n1_session2    cli
    command    n1_session2    show alarm active
    command    n1_session2    exit
    #generate the alarms on the device
    Generate_Alarm_General    n1_session2
    command    n1_session2    cli
    #Verify if the alarms are generated from the CLI session.
    ${alarm_details}=    command    n1_session2    show alarm active
    Verify_Alarm_General    ${alarm_details}
    [Teardown]    Teardown Alarms_Active_Category_GENERAL    n1_session2

*** Keywords ***
Teardown Alarms_Active_Category_GENERAL
    [Arguments]    ${DUT}
    [Documentation]    Disconnect from the device.
    [Tags]    @author=Shesha Chandra
    Clear_Alarm_General    ${DUT}
    Disconnect    ${DUT}
