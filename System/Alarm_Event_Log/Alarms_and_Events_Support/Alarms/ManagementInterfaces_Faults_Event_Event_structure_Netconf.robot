*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Event_structure_Netconf
    [Documentation]    Testcase to verify the if the event definition supports the following attributes: InstanceId,Name,Description,Category,Time,Sequence number,Module,Additional text.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-336    @globalid=2226258    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    ${events_netconf}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events_netconf}=    Convert to string    ${events_netconf}
    Should contain    ${events_netconf}    instance-id
    Should contain    ${events_netconf}    name
    Should contain    ${events_netconf}    description
    Should contain    ${events_netconf}    category
    Should contain    ${events_netconf}    time
    Should contain    ${events_netconf}    device-sequence-number
    Should contain    ${events_netconf}    module
    Should contain    ${events_netconf}    details
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Event_structure_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Event_structure_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}
