*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags       @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_system_Cli
    [Documentation]    Testcase to verify the if the event is generated when the system reloads. This testcase will reset the device.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-303    @globalid=2226224    @priority=P1    @user_interface=Cli
    Command    n1_session1    clear active event
    #schdule the reload for the device from the CLI.
    ${reload_str}    release_cmd_adapter    n1_session1    ${prov_reload_cmd}
    cli    n1_session1    reload ${reload_str}    prompt=Proceed with reload\\? \\[y/N\\]
    cli    n1_session1    y    timeout=60

    ${events}=    command    n1_session1    show event
    ${events_detail}=    command    n1_session1    show event detail
    Should contain    ${events_detail}    reload
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_system_Cli    n1_session1

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_system_Cli
    [Arguments]    ${DUT}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #wait for the system to boot.The system takes around 8 seconds to reboot after we issue "reload" command. Hence using the sleep command.
    sleep    5
    Wait Until Keyword Succeeds    24x    20 seconds    Check Status    n1_session1
    Command    ${DUT}    clear active event
    Disconnect    ${DUT}

Check Status
    [Arguments]    ${DUT}
    [Documentation]    To check the version of the DUT
    [Tags]    @author=Shesha Chandra
    command    n1_session1    cli
    command    n1_session1    Show version
