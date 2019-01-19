*** Settings ***
Documentation     The E3-2 MUST allow a user to disable logging of alarms using syslog.
...    The user MUST be able to turn off syslog logging for all alarms, or specific alarm types for a specific syslog remote server.
Resource          ./base.robot


*** Test Cases ***
tc_The_system_MUST_all_alarm_logging_using_syslog_to_be_disabled
    [Documentation]    1	Configure two logging hosts with admin state enabled.
    ...    2	Trigger alarm.	Verify syslog notifications are received by logging hosts.
    ...    3	Disable admin state of one of the logging hosts.
    ...    4	Trigger alarm.	Verify syslog notifications are no longer received on the disabled logging host. Notifications are still received on enabled logging host.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-106    @globalid=2210633    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure two logging hosts with admin state enabled.
    log    STEP:2 Trigger alarm. Verify syslog notifications are received by logging hosts.
    sleep   2s
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    ${card_type}
    log    STEP:3 Disable admin state of one of the logging hosts.
    Prov_syslog_server    eutA    ${sys_server1}    admin-state=disabled
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    log    STEP:4 Trigger alarm. Verify syslog notifications are no longer received on the disabled logging host. Notifications are still received on enabled logging host.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    check_log_empty_file    h1    ${log_path}    ${client_ip}    ${card_type}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    prov server
    Prov_syslog_server    eutA    ${sys_server1}


case teardown
    [Documentation]    case teardown
    [Arguments]
    log    dprv server
    dprov_syslog_server    eutA    ${sys_server1}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
