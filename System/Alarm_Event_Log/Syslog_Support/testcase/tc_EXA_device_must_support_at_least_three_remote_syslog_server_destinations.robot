*** Settings ***
Documentation     EXA device must support at least three remote syslog server destinations
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_support_at_least_three_remote_syslog_server_destinations
    [Documentation]    1	Configure a single syslog server destination and verify it sends syslog messages.
    ...    2	Vary the log-level for the syslog server destination and verify that only the configured log-level or higher messages are sent by generating events/alarms; but not messages lower than the set log-level.	Messages should be sent to the server destination
    ...    3	Configure 2 more syslog servers.
    ...    4	Verify that you can only configure at most 3 syslog server destinations and they can all receive syslog messages.
    ...    5	Repeat steps 2 with the 3 syslog server destinations.	Verify that syslog messages are properly received at each server.
    ...    6	Show the syslog servers and verify the configuration is correctly displayed.
    ...    7	Disable a syslog server destination and repeat steps 2 and 3 again.	The disabled syslog server destination should not receive syslog messages.
    ...    8	Delete a syslog server and verify messages are not being sent to the server destination and was properly removed.
    [Tags]       @author=Ronnie_Yi   @jira=EXA-29615   @TCID=AXOS_E72_PARENT-TC-94    @globalid=2210621    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination and verify it sends syslog messages.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    ${card_type}
    log    STEP:2 Vary the log-level for the syslog server destination and verify that only the configured log-level or higher messages are sent by generating events/alarms; but not messages lower than the set log-level. Messages should be sent to the server destination
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[5]}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep  2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    lmd
    log    STEP:3 Configure 2 more syslog servers.
    Prov_syslog_server    eutA    ${sys_server2}
    Prov_syslog_server    eutA    ${sys_server3}
    log    STEP:4 Verify that you can only configure at most 3 syslog server destinations and they can all receive syslog messages.
    cli    eutA    configure
    ${tmp}    cli    eutA    logging host ${sys_server4}
    ${tmp}    cli    eutA    logging host ${sys_server5}
    should contain    ${tmp}    Aborted: too many 'logging host'
    cli    eutA    end
    log    STEP:5 Repeat steps 2 with the 3 syslog server destinations. Verify that syslog messages are properly received at each server.
    log    STEP:6 Show the syslog servers and verify the configuration is correctly displayed.
    check_logging_config     eutA    ${sys_server1}    ${Default_Transport_Protocol}    ${Syslog_default_port}    ${severity_level[5]}    ${Default_Admin_State}
    log    STEP:7 Disable a syslog server destination and repeat steps 2 and 3 again. The disabled syslog server destination should not receive syslog messages.
    Prov_syslog_server    eutA    ${sys_server1}    admin-state=disabled
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    check_log_empty_file    h1    ${log_path}    ${client_ip}    ${card_type}
    log    STEP:8 Delete a syslog server and verify messages are not being sent to the server destination and was properly removed.
    Prov_syslog_server    eutA    ${sys_server1}    admin-state=enabled
    dprov_syslog_server    eutA    ${sys_server1}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    check_log_empty_file    h1    ${log_path}    ${client_ip}    ${card_type}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    prov server
    Prov_syslog_server    eutA    ${sys_server1}     log-level=${severity_level[7]}

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    dprv server
    run keyword and ignore error    cli    eutA    end
    run keyword and ignore error    dprov_syslog_server    eutA    ${sys_server1}
    dprov_syslog_server    eutA    ${sys_server2}
    dprov_syslog_server    eutA    ${sys_server3}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}