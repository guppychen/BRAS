*** Settings ***
Documentation     The unique id identifies the specific message (alpha numeric). This is not an message instance id, but a message definition id. It is immutable.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_include_an_EXA_scoped_unique_id_for_the_message
    [Documentation]    1	Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS"	Configuration should be successful.
    ...    2	Generate an event or alarm that would be sent to the syslog server.
    ...    3	Verify that the event or alarm was logged in the syslog server.	Event or alarm generated should have sent a syslog message to the server.
    ...    4	View the syslog message on the server and verify the message includes a unique ID.
    ...    5	Generate the same event or alarm and verify the syslog message sent has the same unique ID.
    ...    6	Generate a different event or alarm and verify the syslog message sent has a different ID the previous syslog message from step 5.
    ...    7	Try various scenarios to generate various syslogs messages.
    ...    8	Verify that messages of the same event/alarm contains the same ID number and messages from different events/alarms contain unique IDs.
    [Tags]       @author=Ronnie_Yi    @jira=EXA-29615  @TCID=AXOS_E72_PARENT-TC-102    @globalid=2210629    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS" Configuration should be successful.
    log    STEP:2 Generate an event or alarm that would be sent to the syslog server.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    log    STEP:3 Verify that the event or alarm was logged in the syslog server. Event or alarm generated should have sent a syslog message to the server.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Name:db-change
    log    STEP:4 View the syslog message on the server and verify the message includes a unique ID.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Id:705
    log    STEP:5 Generate the same event or alarm and verify the syslog message sent has the same unique ID.
    log    STEP:6 Generate a different event or alarm and verify the syslog message sent has a different ID the previous syslog message from step 5.
    log    STEP:7 Try various scenarios to generate various syslogs messages.
    log    STEP:8 Verify that messages of the same event/alarm contains the same ID number and messages from different events/alarms contain unique IDs.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}
    configure    eutA    ntp server ${ntp_server} ${ntp_server_ip}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Name:ntp-server-reachability
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    Id:1918


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    prov server
    Prov_syslog_server    eutA    ${sys_server1}    log-level=${severity_level[7]}

case teardown
    [Documentation]    case teardown
    [Arguments]
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    dprov_syslog_server    eutA    ${sys_server1}
    delete_config_object    eutA    ntp server    ${ntp_server}
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    clear_log_file    h1    ${log_path}    ${client_ip}    ${card_type}