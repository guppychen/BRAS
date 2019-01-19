*** Settings ***
Documentation     Changed GMT to UTC to be consistent with other requirements. I do not believe this is an issue for Syslog as it should be reported in UTC. Differences for syslog are minor. The key difference is the start of the day 00:00 vs. 12:00
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_include_a_timestamp_relative_to_UTC_with_all_syslog_messages
    [Documentation]    1	Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS"	Configuration should be successful.
    ...    2	Generate an event or alarm that would be sent to the syslog server.		Disabling and enabling a interface should generate an event.
    ...    3	Verify that the event or alarm was logged in the syslog server.	Event or alarm generated should have sent a syslog message to the server.
    ...    4	View the syslog message on the server and verify the timestamp is in UTC format.	Timestamp should be in UTC format.
    [Tags]       @author=Ronnie_Yi  @jira=EXA-29615    @TCID=AXOS_E72_PARENT-TC-97    @globalid=2210624    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS" Configuration should be successful.
    log    STEP:2 Generate an event or alarm that would be sent to the syslog server. Disabling and enabling a interface should generate an event.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    log    STEP:3 Verify that the event or alarm was logged in the syslog server. Event or alarm generated should have sent a syslog message to the server.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    db-change
    log    STEP:4 View the syslog message on the server and verify the timestamp is in UTC format. Timestamp should be in UTC format.
    ${tmp}    cli     h1    tail --line=60 ${log_path}${client_ip}.log
    should match regexp    ${tmp}    \\w+\\s+\\d+\\s+\\d+:\\d+:\\d+

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    prov server
    Prov_syslog_server    eutA    ${sys_server1}   log-level=${severity_level[7]}

case teardown
    [Documentation]    case teardown
    [Arguments]
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    dprov_syslog_server    eutA    ${sys_server1}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}