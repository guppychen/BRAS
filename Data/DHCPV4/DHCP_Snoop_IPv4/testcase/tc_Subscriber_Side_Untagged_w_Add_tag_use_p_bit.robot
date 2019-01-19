*** Settings ***
Documentation     Subscriber Side Untagged w/ Add-tag use-p-bit
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_Untagged_w_Add_tag_use_p_bit
    [Documentation]    1	Subscriber Side Untagged w/ Add-tag use-p-bit: Enable DHCP snooping service to access interface with untagged subscriber traffic and add-tag tag action with use-p-bit. Force a client to obtain an IP address via DHCP capturing the DHCP conversation. Display DHCP lease table. -> DHCP address is obtained by client with p-bit values in the US direction changed to the p-bit value defined in the service tag. Client lease entry present in DHCP lease table. Note: Not available as part of tag-action on ENET.  Policy Maps may be used.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-736    @globalid=2307080    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Subscriber Side Untagged w/ Add-tag use-p-bit: Enable DHCP snooping service to access interface with untagged subscriber traffic and add-tag tag action with use-p-bit. Force a client to obtain an IP address via DHCP capturing the DHCP conversation. Display DHCP lease table. -> DHCP address is obtained by client with p-bit values in the US direction changed to the p-bit value defined in the service tag. Client lease entry present in DHCP lease table. Note: Not available as part of tag-action on ENET. Policy Maps may be used. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}    ovlan_pbit=${stag_pbit}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    save_and_analyze_packet_on_port    tg1    service_p1    bootp.dhcp==1 and vlan.priority==${stag_pbit}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
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
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}    set-stag-pcp=${stag_pbit}

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