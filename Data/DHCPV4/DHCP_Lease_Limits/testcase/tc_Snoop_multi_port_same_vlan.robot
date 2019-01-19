*** Settings ***
Documentation     Snoop multi port same vlan
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Snoop_multi_port_same_vlan
    [Documentation]    1	Enable DHCP snoop on ont Eth-port A and port B	Configuration Takes
    ...    2	Configure DHCP lease limit to 5 	Configuration Takes
    ...    3	Force 6 subscribers to obtain an IP address via DHCP on port A	Only 5 subscribers obtain an IP address on the port.
    ...    4	Force 6 subscribers to obtain an IP address via DHCP on port b	Only 5 subscribers obtain an IP address on the port.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2098    @globalid=2343906    @subfeature=DHCP_Lease_Limits    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP snoop on ont Eth-port A and port B Configuration Takes
    log    STEP:2 Configure DHCP lease limit to 5 Configuration Takes
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit ${lease_limit}
    log    STEP:3 Force 6 subscribers to obtain an IP address via DHCP on port A Only 5 subscribers obtain an IP address on the port.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}    session=${lease_number_1}
    tg save config into file   tg1   /tmp/${TEST NAME}.xml
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${lease_limit}
    Tg Control Dhcp Client    tg1    ${group_name}    stop
#    Tg Delete Dhcp Client    tg1    ${client_name}
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    0
    log    STEP:4 Force 6 subscribers to obtain an IP address via DHCP on port b Only 5 subscribers obtain an IP address on the port.
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_2}    session=${lease_number_1}
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    run keyword and ignore error    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases
    wait until keyword succeeds    ${lease_wait_time}    1    check_l3_hosts    eutA    ${lease_limit}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=1
    subscriber_point_add_svc    subscriber_point2    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2
#    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
#    sleep    ${wait_ont_come_back_in_reality}

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cfg_prefix=1
    subscriber_point_remove_svc    subscriber_point2    ${Qtag_vlan_2}    ${stag_vlan}    cfg_prefix=2
    prov_dhcp_profile    eutA    ${l2_profile_name}    no lease-limit

