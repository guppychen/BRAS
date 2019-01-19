*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${alarm_act}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> \ \ <get> \ \ \ \ <filter> \ \ \ \ \ \ <status xmlns="http://www.calix.com/ns/exa/base"> \ \ \ \ \ \ \ <system> \ \ \ \ \ \ \ \ \ \ <alarm> \ \ \ \ \ \ \ \ \ \ \ \ <active> \    \    \    </active> \ \ \ \ \ \ \ \ \ \ </alarm> \ \ \ \ \ \ \ \ </system> \ \ \ \ \ \ </status> \ \ \ \ </filter> \ \ </get> </rpc> ]]>]]>

*** Test Cases ***
Alarms_Active_Category_GENERAL_netconf
    [Documentation]    The purpose of this test is to verify the CLI shows the correct information in the alarm, a Netconf notification is sent, the alarm is sent to the syslog server, and an SNMP trap/inform is sent. Reset the device to clear all the alarm.
    [Tags]  dual_card_not_support  @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-204   @user=root    @globalid=2226113    @priority=P1    @user_interface=Netconf
    command    n1_session2    cli
    command    n1_session2    show alarm active
    command    n1_session2    exit
    #generate the alarms on the device
    Generate_Alarm_General    n1_session2
    command    n1_session2    cli
    #Verify if the alarms are generated from the Netconf session.
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${alarm_active}=    Netconf Raw    n1_session3    xml=${alarm_act}
    ${alarm_active}=    Convert to string    ${alarm_active}
    Verify_Alarm_General    ${alarm_active}
    [Teardown]    Teardown Alarms_Active_Category_GENERAL_netconf    n1_session2    n1_session3

*** Keywords ***
Teardown Alarms_Active_Category_GENERAL_netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Clear_Alarm_General    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
