*** Settings ***
Documentation     option82 default setting
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_option82_default_setting
    [Documentation]    1	create an id-profile with default setting, and show default setting of file	default circuit-id "%SystemId %IfType %Port:%QTag".remote id is empty
    ...    2	create an l2-dhcp-profile with default setting, and link id-profile to it	configuration is done
    ...    3	check ont interface default option82-action	action is insert
    ...    4	get a dhcp lease from subscriber side, and capture packets from the uplink	success, circuit is work as configured
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2200    @globalid=2344016    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create an id-profile with default setting, and show default setting of file default circuit-id "%SystemId %IfType %Port:%QTag".remote id is empty
    cli_show_default_enable    eutA
    log    to wait for command is accepted by oam in reality
    sleep    3s
    ${tmp}    cli    eutA    show running-config id-profile ${id_profile_name}
    should match regexp    ${tmp}    circuit-id    "%SystemId %IfType %Port:%QTag"
    should match regexp    ${tmp}    remote-id  ""
    log    STEP:2 create an l2-dhcp-profile with default setting, and link id-profile to it configuration is done
    log    STEP:3 check ont interface default option82-action action is insert
    ${tmp}    Axos Cli With Error Check    eutA    show running-config interface ont-ethernet ${service_model.subscriber_point1.name}
    should match regexp    ${tmp}    option82-action\\s+insert
    log    STEP:4 get a dhcp lease from subscriber side, and capture packets from the uplink success, circuit is work as configured
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    ${type}    get_dhcp_option82_expected_port_type    subscriber_point1
    ${port}    get_dhcp_option82_exported_port    subscriber_point1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname} ${type} ${port}:${Qtag_vlan}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    cli_show_default_disable    eutA