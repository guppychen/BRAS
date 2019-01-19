*** Settings ***
Documentation     DHCPv4 and DHCPv6 Relay must support binding of Circuit ID/Interface ID and Remote ID configurations to a specific SVLAN
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_config_per_VLAN
    [Documentation]    1	Create ID profile A	Provisioning Taken
    ...    2	Create ID profile B with a different circuit ID than ID profile A	Provisioning Taken
    ...    3	Create DHCP profile A using ID profile A	Provisioning Taken
    ...    4	Create DHCP profile B using ID profile B	Provisioning Taken
    ...    5	Create VLAN A	Provisioning Taken
    ...    6	Add DHCP profile A to VLAN A	Provisioning Taken
    ...    7	Create VLAN B	Provisioning Taken
    ...    8	Add DHCP profile B to VLAN B	Provisioning Taken
    ...    9	Add VLAN A and VLAN B to interface	Provisioning Taken
    ...    10	Force subscriber to obtain an IPv4 address via DHCP on VLAN A	Subscriber should send a DHCP request and receive and IPv4 address.
    ...    11	Capture entire DHCPv4 transaction.	Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID should match id profile A.
    ...    12	Force subscriber to obtain an IPv4 address via DHCP on VLAN B	Subscriber should send a DHCP request and receive and IPv4 address.
    ...    13	Capture entire DHCPv4 transaction.	Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID should match id profile B.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2229    @globalid=2344045    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:10 Force subscriber to obtain an IPv4 address via DHCP on VLAN A Subscriber should send a DHCP request and receive and IPv4 address.
    log    STEP:11 Capture entire DHCPv4 transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID should match id profile A.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    create_dhcp_server    tg1    ${server_name_2}    service_p1    ${server_mac_2}     ${server_ip_2}     ${lease_start_2}    ${Qtag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_2}
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    ${type}    get_dhcp_option82_expected_port_type    subscriber_point1
    ${port}    get_dhcp_option82_exported_port    subscriber_point1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname} ${type} ${port}:
    check_no_dhcp_option82    tg1    subscriber_p1
    log    STEP:12 Force subscriber to obtain an IPv4 address via DHCP on VLAN B Subscriber should send a DHCP request and receive and IPv4 address.
    log    STEP:13 Capture entire DHCPv4 transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID should match id profile B.
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    Tg Control Dhcp Server    tg1    ${server_name}    stop
    wait until keyword succeeds    10    1    check_l3_hosts    eutA    0
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name_2}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    check_l3_hosts    eutA    1    ${Qtag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    check_dhcp_option82_circuit_id    tg1    service_p1   ${hostname}
    check_dhcp_option82_remote_id    tg1    service_p1    ${Qtag_vlan}
    check_no_dhcp_option82    tg1    subscriber_p1


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP:1 Create ID profile A Provisioning Taken
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}
    log    STEP:2 Create ID profile B with a different circuit ID than ID profile A Provisioning Taken
    log    STEP:3 Create DHCP profile A using ID profile A Provisioning Taken
    log    STEP:4 Create DHCP profile B using ID profile B Provisioning Taken
    log    STEP:5 Create VLAN A Provisioning Taken
    log    STEP:6 Add DHCP profile A to VLAN A Provisioning Taken
    log    STEP:7 Create VLAN B Provisioning Taken
    log    STEP:8 Add DHCP profile B to VLAN B Provisioning Taken
    log    STEP:9 Add VLAN A and VLAN B to interface Provisioning Taken
    prov_id_profile    eutA    ryi    circuit-id=%Hostname    remote-id=%STag
    prov_dhcp_profile    eutA    ryi    id-name ryi
    prov_vlan    eutA    ${Qtag_vlan}    l2-dhcp-profile=ryi
    service_point_add_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2
    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
    sleep    ${wait_ont_come_back_in_reality}

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cfg_prefix=2
    service_point_remove_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2
    delete_config_object    eutA    vlan    ${Qtag_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ryi
    dprov_id_profile    eutA    ryi
    service_point_add_vlan    service_point_list1    ${stag_vlan}
