*** Settings ***
Documentation     All Calix Platform Provisioning of Circuit ID/Interface ID and RemoteID format must be IP version agnostic
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_IP_Version_Agnostic_Provisioning
    [Documentation]    1	Setup DHCP Profile with Circuit ID/Interface ID and remote ID provisioning	Provisioning Taken
    ...    2	Add DHCP profile to service instance on an INNI Interface using IPv4	Provisioning Taken
    ...    3	Send DHCP Traffic on Interface A without Circuit ID/Interface ID information already in the packet	Packet should be relayed upstream to server
    ...    4	Analyze DHCP Packets at DHCP Server Side	Option 82 Circuit ID/Interface ID Remote ID should contain EUT circuit id/interface id and remote id
    ...    5	Analyze DHCP Packets at DHCP Client Side	Option 82 Circuit ID/Interface ID Remote ID should be removed
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2220    @globalid=2344036    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Setup DHCP Profile with Circuit ID/Interface ID and remote ID provisioning Provisioning Taken
    log    STEP:2 Add DHCP profile to service instance on an INNI Interface using IPv4 Provisioning Taken
    log    STEP:3 Send DHCP Traffic on Interface A without Circuit ID/Interface ID information already in the packet Packet should be relayed upstream to server
    configure_interface_ont_ethernet    eutA    ${service_model.subscriber_point1.name}   subscriber-id=${desc}
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:4 Analyze DHCP Packets at DHCP Server Side Option 82 Circuit ID/Interface ID Remote ID should contain EUT circuit id/interface id and remote id
    stop_capture    tg1    service_p1
    ${type}    get_dhcp_option82_expected_port_type    subscriber_point1
    ${port}    get_dhcp_option82_exported_port    subscriber_point1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname} ${type} ${port}:${Qtag_vlan}
    check_dhcp_option82_remote_id    tg1    service_p1    ${desc}
    log    STEP:5 Analyze DHCP Packets at DHCP Client Side Option 82 Circuit ID/Interface ID Remote ID should be removed
    stop_capture    tg1    subscriber_p1
    check_no_dhcp_option82    tg1    subscriber_p1



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    remote-id=%Desc


case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    delete_interface_ont_ethernet_configuration    eutA    ${service_model.subscriber_point1.name}    subscriber-id
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id