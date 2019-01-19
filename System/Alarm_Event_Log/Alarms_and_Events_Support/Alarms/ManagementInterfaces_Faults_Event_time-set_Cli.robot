*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_time-set_Cli
    [Documentation]    Testcase to verify the if the events are generated when time is changed manually.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-304    @globalid=2226225    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    command    n1_session1    show clock
    #Set the time for the device from the CLI
    ${clock}=    command    n1_session1    clock set ${clock.time1}
    Should contain    ${clock}    ok
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    System time has been manually set
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_time-set_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_time-set_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    ${cur_time}=    Get current date    result_format=%Y-%m-%dT%H:%M:%S
    command    n1_session1    clock set ${cur_time}
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
