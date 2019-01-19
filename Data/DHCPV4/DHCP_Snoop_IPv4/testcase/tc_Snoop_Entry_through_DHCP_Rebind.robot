*** Settings ***
Documentation     Snoop Entry through DHCP Rebind
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Snoop_Entry_through_DHCP_Rebind
    [Documentation]    1	Snoop Entry through DHCP Rebind: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP. Display DHCP lease table periodically until after DHCP rebind. -> Lease expires time is decremented until an update is received via an DHCP REQUEST/ACK exchange. At that point the lease time is reset to the lease time value in the ACK.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-682    @globalid=2307022    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Snoop Entry through DHCP Rebind: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP. Display DHCP lease table periodically until after DHCP rebind. -> Lease expires time is decremented until an update is received via an DHCP REQUEST/ACK exchange. At that point the lease time is reset to the lease time value in the ACK. All Step action expected Results must be correct
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time_2}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}
    check_lease_expire_time    eutA    ${stag_vlan}    ${lease_start}    ${lease_time_2}
    ${tmp1}    Get_dhcp_lease_first_time    eutA    ${stag_vlan}    ${lease_start}
    ${tmp2}    Get_dhcp_lease_renew_time    eutA    ${stag_vlan}    ${lease_start}
    should be equal as strings    ${tmp1}    ${tmp2}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    Tg Control Dhcp Client    tg1    ${group_name}    rebind
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    sleep    ${STC_wait_time}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}
    check_lease_expire_time_after_renew    eutA    ${stag_vlan}    ${lease_start}    ${lease_time_2}
    Tg Start Arp Nd On All Devices    tg1
    Tg_start_arp_nd_on_all_stream_blocks    tg1

    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}


case teardown
    [Documentation]    case teardown
    [Arguments]
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}