*** Settings ***
Documentation     Platform manager monitors the CPU usage as a percentage. When a threshold is exceeded, a threshold crossing alarm is generated description System CPU usage has exceeded a threshold
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${subscope-id-2609}    <?xml version="1.0" encoding="utf-8"?> <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="101"> <show-alarm-instances-active-subscope xmlns="http://www.calix.com/ns/exa/base"> <id>2609</id> \ </show-alarm-instances-active-subscope> </rpc>]]>]]>

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_netconf
    [Documentation]    Testcase to verify that alarm is generated when the usage of system memory increases.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-227   @user=root   @user=root    @globalid=2226136    @priority=P1    @user_interface=Netconf
    Cli    n1_session2    cli
    #Create alarm from the dcli mode
    Command    n1_session2    clear active event
    Command    n1_session2    exit
    Command    n1_session2    dcli evtmgrd evtpost memory-tca MAJOR
    Cli    n1_session2    cli
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${message}=    Netconf Raw    n1_session3    xml=${subscope-id-2609}
    Should contain    ${message.xml}    memory-tca
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_netconf    n1_session2    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_system-memory-mon-tca_netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    exit
    command    ${DUT}    dcli evtmgrd evtpost memory-tca CLEAR
    Disconnect    ${DUT}
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
