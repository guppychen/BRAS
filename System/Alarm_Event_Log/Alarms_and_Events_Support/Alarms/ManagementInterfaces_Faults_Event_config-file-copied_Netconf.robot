*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${copy-run-start}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <copy-running-startup xmlns="http://www.calix.com/ns/exa/base"> </copy-running-startup> </rpc> ]]>]]>

*** Test Cases ***
ManagementInterfaces_Faults_Event_config-file-copied_Netconf
    [Documentation]    Testcase to verify the events are generated when the config file is copied.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-292   @user=root    @globalid=2226213    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    Command    n1_session1    accept running-config

    ${copy-status}=    Netconf Raw    n1_session3    xml=${copy-run-start}
    ${copy-status}=    Convert to string    ${copy-status}
    Should Contain    ${copy-status}    Copy completed.
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Configuration file was copied
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_config-file-copied_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_config-file-copied_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
