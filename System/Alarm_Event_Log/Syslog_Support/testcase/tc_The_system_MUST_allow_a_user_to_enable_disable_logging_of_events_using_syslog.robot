*** Settings ***
Documentation     The system MUST allow a user to enable/disable logging of events using syslog.
...    The user MUST be able to turn off syslog logging for all events, or specific event types for a specific syslog remote server.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_system_MUST_allow_a_user_to_enable_disable_logging_of_events_using_syslog
    [Documentation]
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-107    @globalid=2210634    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:The system MUST allow a user to enable/disable logging of events using syslog.
    Prov_syslog_server    eutA    ${sys_server1}
    check_logging_config     eutA    ${sys_server1}    ${Default_Transport_Protocol}    ${Syslog_default_port}    ${Default_Log_Level}    ${Default_Admin_State}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[0]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[0]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[1]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[1]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[2]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[2]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[3]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[3]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[4]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[4]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[5]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[5]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[6]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[6]}
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[7]}
    check_logging_config     eutA    ${sys_server1}    level=${severity_level[7]}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    setup

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    dprv server
    dprov_syslog_server    eutA    ${sys_server1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}