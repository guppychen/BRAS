*** Settings ***
Documentation     DHCPv4 Snoop Agent must support configuration of a port to support only 1 lease at a time, with current lease deleted if a DISCOVER is received from a new MAC.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCPv4_Snoop_Agent_must_support_configuration_of_a_port_to_support_only_1_lease_at_a_time_with_current_lease_deleted_if_a_DISCOVER_is_received_from_a_new_MAC
    [Documentation]    1	set dhcp limit to 1, enable single-lease-overwrite
    ...    2	get a DHCP lease with mac1	success
    ...    3	get dhcp lease with a new mac	mac is changed with the same ip
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-700    @globalid=2307040    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 set dhcp limit to 1, enable single-lease-overwrite
    prov_dhcp_profile    eutA    ${l2_profile_name}    lease-limit 1 single-lease-overwrite enabled
    log    STEP:2 get a DHCP lease with mac1 success
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=86400
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}    
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    Tg Delete All Traffic    tg1
    log    STEP:3 get dhcp lease with a new mac mac is changed with the same ip
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    sleep    ${STC_wait_time}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac_2}
    create_bound_traffic_udp    tg1    dhcp_upstream1    subscriber_p1    ${server_name}    ${group_name_2}    10
    create_bound_traffic_udp    tg1    dhcp_downstream1    service_p1    ${group_name_2}    ${server_name}    10
    Tg Start Arp Nd On All Devices    tg1
    Tg_start_arp_nd_on_all_stream_blocks    tg1

    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # Tg Save Config Into File    tg1     /tmp/stream.xml
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    check_l3_hosts    eutA    0



*** Keywords ***
case setup
    [Documentation]        case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

case teardown
    [Documentation]        case teardown
    [Arguments]
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}