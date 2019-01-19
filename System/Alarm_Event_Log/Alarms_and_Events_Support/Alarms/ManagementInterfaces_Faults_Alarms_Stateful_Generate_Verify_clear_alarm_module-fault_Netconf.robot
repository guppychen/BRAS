*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags         @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${alarm_act}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> \ \ <get> \ \ \ \ <filter> \ \ \ \ \ \ <status xmlns="http://www.calix.com/ns/exa/base"> \ \ \ \ \ \ \ <system> \ \ \ \ \ \ \ \ \ \ <alarm> \ \ \ \ \ \ \ \ \ \ \ \ <active> \    \    \    </active> \ \ \ \ \ \ \ \ \ \ </alarm> \ \ \ \ \ \ \ \ </system> \ \ \ \ \ \ </status> \ \ \ \ </filter> \ \ </get> </rpc>

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Netconf
    [Documentation]    Testcase to verify the if the alarm is generated when SFP/SFP+/XFP pluggable device has a fault condition.
    [Tags]  dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang    @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-218   @user=root   @user=root    @globalid=2226127    @priority=P1    @user_interface=Netconf
    command    n1_session2    cli
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault Major    timeout_exception=0    prompt=#
    command    n1_session2    cli
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${alarm}=    Netconf Raw    n1_session3    xml=${alarm_act}
    ${alarm}=    Convert to string    ${alarm}
    Should contain    ${alarm}    module-fault
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Netconf    n1_session2    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault CLEAR
    Disconnect    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
