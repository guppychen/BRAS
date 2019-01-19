*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${Schreload}      <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <reload xmlns="http://www.calix.com/ns/exa/base"> <in>90</in> </reload> </rpc> ]]>]]>

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_scheduled_Netconf
    [Documentation]    Testcase to verify the if the events are generated when reload in scheduled.
    [Tags]   dual_card_not_support   @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-302    @globalid=2226223    @priority=P1    @user_interface=Netconf
    Cli    n1_session1    cli
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    ${clock}=    Netconf Raw    n1_session3    xml=${Schreload}
    Should contain    ${clock.xml}    ok
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    A reload has been scheduled
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_scheduled_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    ${DUT}    stop reload
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
