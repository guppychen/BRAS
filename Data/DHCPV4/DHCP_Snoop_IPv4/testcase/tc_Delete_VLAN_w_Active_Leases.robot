*** Settings ***
Documentation     Delete VLAN w/ Active Leases
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Delete_VLAN_w_Active_Leases
    [Documentation]    1	Delete VLAN w/ Active Leases: Enable VLAN with DHCP snooping and provisioned both services to an access interfce. Force a client on each VLAN to obtain an IP address. The same MACs are used for VLAN A and VLAN B client. Display lease table. The lease timeout should be low. Delete VLAN A from the access interface. Display DHCP lease table. Re-add DHCP Snooping on VLAN A. Display DHCP lease table. Allowing for DHCP rebind time and re-display DHCP lease table. -> All clients DHCP leases are displayed in DHCP lease table prior to disabling DHCP Snooping on VLAN A. After VLAN A service is removed only leases for VLAN B are present. After VLAN A is re-added DHCP Snooping is re-enabled the leases are NOT automatically repopulated until the bind time through DHCP REQUEST/ACK.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-681    @globalid=2307021    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Delete VLAN w/ Active Leases: Enable VLAN with DHCP snooping and provisioned both services to an access interfce. Force a client on each VLAN to obtain an IP address. The same MACs are used for VLAN A and VLAN B client. Display lease table. The lease timeout should be low. Delete VLAN A from the access interface. Display DHCP lease table. Re-add DHCP Snooping on VLAN A. Display DHCP lease table. Allowing for DHCP rebind time and re-display DHCP lease table. -> All clients DHCP leases are displayed in DHCP lease table prior to disabling DHCP Snooping on VLAN A. After VLAN A service is removed only leases for VLAN B are present. After VLAN A is re-added DHCP Snooping is re-enabled the leases are NOT automatically repopulated until the bind time through DHCP REQUEST/ACK. All Step action expected Results must be correct
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
    log    disable snooping on service vlan
    dprov_vlan    eutA     ${stag_vlan}    l2-dhcp-profile
    check_l3_hosts    eutA    0
    prov_vlan    eutA     ${stag_vlan}    l2-dhcp-profile=${l2_profile_name}
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    wait until keyword succeeds    10    1    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}
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
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}