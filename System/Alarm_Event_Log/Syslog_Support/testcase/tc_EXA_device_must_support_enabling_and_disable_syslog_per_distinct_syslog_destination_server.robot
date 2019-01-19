*** Settings ***
Documentation     EXA device must support enabling and disable syslog per distinct syslog destination server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_support_enabling_and_disable_syslog_per_distinct_syslog_destination_server
    [Documentation]    1	Configure a single syslog server destination and verify it sends syslog messages by generating an event or alarm.
    ...    2	Try various scenarios to generate various syslogs messages.	Messages should be sent to the server destination.
    ...    3	Add a second syslog server destination.
    ...    4	Show the syslog servers and verify the configuration is correctly displayed.
    ...    5	Repeat steps 1 and 2. Verify that both syslog servers are receiving the syslog messages.
    ...    6	Disable one of the syslog servers. Use the command "logging host IPV4_ADDRESS admin-state DISABLED"	Configuration should take.
    ...    7	Repeat steps 1 and 2. Verify that only the syslog server that is enabled is receiving syslog messages.	The disabled syslog server should not be receiving any syslog messages.
    ...    8	Remove both configured syslog server and verify they are not shown in the configurations anymore with a show command.
    ...    9	Repeat steps 1 and 2. Verify that the two previously configured syslog server are not receiving any syslog messages.	Syslog servers should not be receiving syslog messages.
    [Tags]       @author=Ronnie_Yi    @jira=EXA-29615  @TCID=AXOS_E72_PARENT-TC-96    @globalid=2210623    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination and verify it sends syslog messages by generating an event or alarm.
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    3 sec
    log    STEP:2 Try various scenarios to generate various syslogs messages. Messages should be sent to the server destination.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Name:db-change
    log    STEP:3 Add a second syslog server destination.
    Prov_syslog_server    eutA    ${sys_server2}
    log    STEP:4 Show the syslog servers and verify the configuration is correctly displayed.
    check_logging_config     eutA    ${sys_server2}    ${Default_Transport_Protocol}    ${Syslog_default_port}    ${Default_Log_Level}    ${Default_Admin_State}
    log    STEP:5 Repeat steps 1 and 2. Verify that both syslog servers are receiving the syslog messages.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Name:db-change
    log    STEP:6 Disable one of the syslog servers. Use the command "logging host IPV4_ADDRESS admin-state DISABLED" Configuration should take.
    Prov_syslog_server    eutA    ${sys_server1}    admin-state=disabled
    log    STEP:7 Repeat steps 1 and 2. Verify that only the syslog server that is enabled is receiving syslog messages. The disabled syslog server should not be receiving any syslog messages.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    check_log_empty_file    h1    ${log_path}    ${client_ip}    ${card_type}
    log    STEP:8 Remove both configured syslog server and verify they are not shown in the configurations anymore with a show command.
    dprov_syslog_server    eutA    ${sys_server1}
    dprov_syslog_server    eutA    ${sys_server2}
    log    STEP:9 Repeat steps 1 and 2. Verify that the two previously configured syslog server are not receiving any syslog messages. Syslog servers should not be receiving syslog messages.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    check_log_empty_file    h1    ${log_path}    ${client_ip}    ${card_type}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    prov server
    Prov_syslog_server    eutA    ${sys_server1}        log-level=${severity_level[7]}

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    dprov_syslog_server    eutA    ${sys_server1}
    run keyword and ignore error    dprov_syslog_server    eutA    ${sys_server2}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}