*** Settings ***
Documentation     EXA device MUST support generating the events and display event details.
Force Tags        @eut=NGPON2-4
Resource          base.robot

*** Test Cases ***
ManagementInterfaces_Faults_Event_reload_system_Netconf
    [Documentation]    Testcase to verify the if the event is generated when the system reloads. This testcase will reset the device.
    [Tags]    @feature=Alarm_Event_Log    @subFeature=Alarms and Events Support    @author=Doris He   @author=Shesha Chandra    @tcid=AXOS_E72_PARENT-TC-303    @globalid=2226224    @priority=P1    @user_interface=Netconf
    Command    n1_session1    clear active event
    ${subscribe}=    Netconf Raw    n1_session3    xml=${netconf.subscription}
    Should contain    ${subscribe.xml}    ok
    #schdule the reload for the device from the CLI.
    ${reload_str}    release_cmd_adapter    n1_session1    ${prov_reload_cmd}
    cli    n1_session1    reload ${reload_str}    prompt=Proceed with reload\\? \\[y/N\\]
    cli    n1_session1    y    timeout=60
    ${events}=    command    n1_session1    show event
    ${events_netconf}=    Netconf Raw    n1_session3    xml=${netconf.showevent}
    ${events_netconf}=    Convert to string    ${events_netconf}
    Should contain    ${events_netconf}    reload
    [Teardown]    Teardown ManagementInterfaces_Faults_Event_reload_system_Netconf    n1_session1    n1_session3

*** Keywords ***
Teardown ManagementInterfaces_Faults_Event_reload_system_Netconf
    [Arguments]    ${DUT}    ${DUT1}
    [Documentation]    Rollback the actions
    [Tags]    @author=Shesha Chandra
    #wait for the system to boot.The system takes around 5 seconds to reboot after we issue "reload" command. Hence using the sleep command.
    sleep    5
    Wait Until Keyword Succeeds    24x    20 seconds    Check Status    n1_session1
    Command    ${DUT}    clear active event
    Netconf Raw    ${DUT1}    xml=${netconf.closesession}
    Disconnect    ${DUT}

Check Status
    [Arguments]    ${DUT}
    [Documentation]    To check the version of the DUT
    [Tags]    @author=Shesha Chandra
    command    n1_session1    cli
    command    n1_session1    Show version
