*** Settings ***
Documentation     Note: Calix can use specific local facilty per device type application logic. For instance; the E5-520/308 can use local 7.
...    Note: For existing applications on our platforms based on third party source, other facilities can be used if they apply, i.e. auth, authpriv, daemon, ftp, kern, user etc... as long as they are consistently used.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_EXA_device_must_include_the_source_facility_with_all_syslog_messages
    [Documentation]    1	Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS"	Configuration should be successful.
    ...    2	Generate an event or alarm that would be sent to the syslog server.
    ...    3	Verify that the event or alarm was logged in the syslog server.	Event or alarm generated should have sent a syslog message to the server.
    ...    4	View the syslog message on the server and verify the syslog message contains the source facility (E5-520/308/etc.)	Source facility should be included in the syslog message.
    ...    5	Repeat steps 1-4 with a different type of device. Verify the syslog messages from the new device also displays the source facility and should be different.
    [Tags]       @author=Ronnie_Yi   @jira=EXA-29615  @TCID=AXOS_E72_PARENT-TC-98    @globalid=2210625    @subfeature=Syslog_Support    @feature=Alarm_Event_Log    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a single syslog server destination. Use command "logging host IPv4_ADDRESS" Configuration should be successful.
    log    STEP:2 Generate an event or alarm that would be sent to the syslog server.
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    2s
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep   2s
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
#    cli     h1    sudo chmod -R 777 ${log_path}    prompt=:    timeout_exception=0
#    cli     h1    ${sudo_pwd}    timeout_exception=0
    log    STEP:3 Verify that the event or alarm was logged in the syslog server. Event or alarm generated should have sent a syslog message to the server.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    db-change
    log    STEP:4 View the syslog message on the server and verify the syslog message contains the source facility (E5-520/308/etc.) Source facility should be included in the syslog message.
    log    STEP:5 Repeat steps 1-4 with a different type of device. Verify the syslog messages from the new device also displays the source facility and should be different.
    wait until keyword succeeds    ${wait_log_transfer}    ${check_log_interval}    check_log_result    h1    ${log_path}    ${client_ip}    ${card_type}

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