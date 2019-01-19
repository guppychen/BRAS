*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_Event_structure_Cli
    [Documentation]    Testcase to verify the if the event definition supports the following attributes: InstanceId,Name,Description,Category,Time,Sequence number,Module,Additional text.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-336    @globalid=2226258    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    ${events}=    command    n1_session1    show event detail
    Log    ${events}
    #Verify if the event details has all the attributes.
    Should contain    ${events}    instance-id
    Should contain    ${events}    name
    Should contain    ${events}    description
    Should contain    ${events}    category
    Should contain    ${events}    time
    Should contain    ${events}    device-sequence-number
    Should contain    ${events}    module
    Should contain    ${events}    details
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_Event_structure_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_Event_structure_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
