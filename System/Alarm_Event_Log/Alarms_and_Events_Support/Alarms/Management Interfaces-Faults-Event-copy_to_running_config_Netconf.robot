*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${copy-run-start}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <copy-startup-running xmlns="http://www.calix.com/ns/exa/base"> </copy-startup-running> </rpc> ]]>]]>

*** Test Cases ***
Management Interfaces-Faults-Event-copy_to_running_config_Netconf
    [Documentation]    Testcase to verify the if the events are generated when config file is copied to running-config.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-291   @user=root    @globalid=2226212    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${copy-status}=    Netconf Raw    n1_session3    xml=${copy-run-start}
    ${copy-status}=    Convert to string    ${copy-status}
    Should Contain    ${copy-status}    Copy completed.
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Copy into running configuration was done
    [Teardown]    Teardown Management Interfaces-Faults-Event-copy_to_running_config_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown Management Interfaces-Faults-Event-copy_to_running_config_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
