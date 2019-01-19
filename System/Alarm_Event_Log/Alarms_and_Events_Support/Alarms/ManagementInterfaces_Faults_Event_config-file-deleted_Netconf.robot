*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Variables ***
${copy-run-start}    <rpc message-id="101" xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"> <copy-startup-running xmlns="http://www.calix.com/ns/exa/base"> </copy-startup-running> </rpc> ]]>]]>

*** Test Cases ***
ManagementInterfaces_Faults_Event_config-file-deleted_Netconf
    [Documentation]    Testcase to verify the if the events are generated when config file is deleted.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-293   @user=root   @user=root    @globalid=2226214    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    Command    n1_session1    clear active event
    #create a new config file by copying the running-config to a new file.
    Command    n1_session1    accept running-config
    ${copy-status}=    Command    n1_session1    copy config from running-config to config.txt
    Should contain    ${copy-status}    Copy completed.
    #Delete the config file created by the user
    ${copy-status}=    Command    n1_session1    delete file config filename config.txt
    Should contain    ${copy-status}    OK
    ${events}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events}=    Convert to string    ${events}
    Should contain    ${events}    Configuration file was deleted
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_config-file-deleted_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_config-file-deleted_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
