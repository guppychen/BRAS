*** Settings ***
Documentation     A user with the appropriate permissions must be able to clear/purge the event log. The clearing of the event log needs to be recorded. We need to record who did and when it was done. This needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the event log
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
EXA device must support the ability to clear_purge the event log_Cli
    [Documentation]    Testcase to verify if the events can be cleared. Once the event is cleared it must be verified if the clear-event is recorded.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=myang   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-285    @globalid=2226205    @priority=P1    @user_interface=Cli
    #verify that some events are already present on the device
    ${event}=    command    n1_session1    show event
    command    n1_session1    clear active event
    ${clear_event}=    command    n1_session1    show event
    Should contain    ${clear_event}    total-count 1
    [Teardown]    Teardown EXA device must support the ability to clear_purge the event log_Cli    n1_session1

*** Keywords ***
Teardown EXA device must support the ability to clear_purge the event log_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    Disconnect    ${DUT}
