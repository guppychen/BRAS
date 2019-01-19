*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
Management Interfaces-Faults-Event-copy_to_running_config_Cli
    [Documentation]    Testcase to verify the if the events are generated when config file is copied to running-config.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-291   @user=root    @globalid=2226212    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    ${copy-status}=    Command    n1_session1    copy startup-config running-config
    Should contain    ${copy-status}    Copy completed.
    ${events}=    command    n1_session1    show event detail
    Should contain    ${events}    Copy into running configuration was done
    [Teardown]    Teardown Management Interfaces-Faults-Event-copy_to_running_config_Cli    n1_session1

*** Keywords ***
Teardown Management Interfaces-Faults-Event-copy_to_running_config_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}
