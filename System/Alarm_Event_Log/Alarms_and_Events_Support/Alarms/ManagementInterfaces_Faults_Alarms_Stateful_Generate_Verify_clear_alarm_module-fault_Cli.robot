*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Cli
    [Documentation]    Testcase to verify the if the events are generated when time is changed manually. Since we are generating the alarm by enabling the admin-state of the PON port, atleast one PON port must be in disabled state with no connection.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-218   @user=root   @user=root    @globalid=2226127    @priority=P1    @user_interface=Cli
    command    n1_session2    cli
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault Major    timeout_exception=0    prompt=#
    command    n1_session2    cli
    ${alarm}=    command    n1_session2    show alarm active
    Should contain    ${alarm}    module-fault
    [Teardown]    Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Cli    n1_session2

*** Keywords ***
Teardown ManagementInterfaces_Faults_Alarms_Stateful_Generate_Verify_clear_alarm_module-fault_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    command    n1_session2    exit
    command    n1_session2    dcli evtmgrd evtpost module-fault CLEAR
    Disconnect    ${DUT}
