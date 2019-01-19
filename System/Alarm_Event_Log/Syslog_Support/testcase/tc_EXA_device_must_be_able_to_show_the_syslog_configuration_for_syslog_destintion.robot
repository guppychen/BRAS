*** Settings ***
Documentation     The remote, and local(file, console) syslog configuration must be reportable via the management plane CLI, EWI and netconf.
...    The remote syslog includes: host, port, protocol, syslog severity level (if filtering based on severity is supported), status (enabled/disabled)
...    The local syslog includes: file, syslog severity level (if filtering based on severity is supported), status (enabled/disabled)
...    Note: For CLI - suggest Cisco consistent command with a 'show logging' command that summarizes the syslog configuration for remote
...    Note: Syslog severity level refers to threshold for logging of syslog messages to the particular destination.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_be_able_to_show_the_syslog_configuration_for_syslog_destintion
    [Documentation]    1	Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS"	Configuration should be successful.
    ...    2	Execute the show command to view the syslog server configuration. Use "show logging" command	Syslog configurations should be displayed.
    ...    3	Verify the syslog configurations contain the correct default values and the host name is correct.	Transport protocol should be UDP. Port should be 514. Log level should be WARN. Admin state should be enabled.
    ...    4	Modify the transport protocol and verify the show command displays the newly configured transport.
    ...    5	Issue a no command on the transport protocol for the syslog server and execute the show command again.	The transport protocol should be set back to the default value.
    ...    6	Repeat steps 4 and 5 with the syslog destination port, log level, and admin state.	Configuration changes should be seen when executing the show command.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-100    @globalid=2210627    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS" Configuration should be successful.
    Prov_syslog_server    eutA    ${sys_server1}
    log    STEP:2 Execute the show command to view the syslog server configuration. Use "show logging" command Syslog configurations should be displayed.
    log    STEP:3 Verify the syslog configurations contain the correct default values and the host name is correct. Transport protocol should be UDP. Port should be 514. Log level should be WARN. Admin state should be enabled.
    check_logging_config     eutA    ${sys_server1}    ${Default_Transport_Protocol}    ${Syslog_default_port}    ${Default_Log_Level}    ${Default_Admin_State}
    log    STEP:4 Modify the transport protocol and verify the show command displays the newly configured transport.
    Prov_syslog_server    eutA    ${sys_server1}    transport=${Secure_Transport_Protocol}
    check_logging_config     eutA    ${sys_server1}    protocol=${Secure_Transport_Protocol}
    log    STEP:5 Issue a no command on the transport protocol for the syslog server and execute the show command again. The transport protocol should be set back to the default value.
    dprov_syslog_server    eutA    ${sys_server1}     No    transport
    check_logging_config     eutA    ${sys_server1}    protocol=${Default_Transport_Protocol}
    log    STEP:6 Repeat steps 4 and 5 with the syslog destination port, log level, and admin state. Configuration changes should be seen when executing the show command.
    Prov_syslog_server    eutA    ${sys_server1}    port=${configure_port}
    check_logging_config     eutA    ${sys_server1}     port=${configure_port}
    dprov_syslog_server    eutA    ${sys_server1}     No    port
    check_logging_config     eutA    ${sys_server1}     port=${Syslog_default_port}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    setup


case teardown
    [Documentation]    case teardown
    [Arguments]
    log    dprov server
    dprov_syslog_server    eutA    ${sys_server1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}