*** Settings ***
Documentation     (TR101-format)DHCP Relay Enabled insert Policy .change-tag
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc__TR101_format_DHCP_Relay_Enabled_insert_Policy_change_tag
    [Documentation]    1	Create service with target tag-action combined	Succeed
    ...    2	configure remote-id/circuit-id as '%SystemId%IfType%Shelf%Slot%Port%OntID%OntPort%STag%CTag'	success
    ...    3	Force a client to obtain a dynamic address
    ...    4	Capture the DHCP V4 conversation	Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2207    @globalid=2344023    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:3 Force a client to obtain a dynamic address
    log    STEP:4 Capture the DHCP V4 conversation Opt82 is inserted into DHCP frames with Remote ID and valid circuit ID
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
    ${ont_port}    get_dhcp_option82_expected_ont_port_number    subscriber_point1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname}${type}${shelf}${slot}${port}${service_model.subscriber_point1.attribute.ont_id}${ont_port}${stag_vlan}




*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP:1 Create service with target tag-action combined Succeed
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    log    STEP:2 configure remote-id/circuit-id as '%SystemId%IfType%Shelf%Slot%Port%OntID%OntPort%STag%CTag' success
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%SystemId%IfType%Shelf%Slot%Port%OntID%OntPort%STag%CTag

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id