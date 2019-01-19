*** Settings ***
Documentation     Subscriber Side VLAN Membership Double Tagged Subscriber Traffic with stag promote and ctag 6
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_VLAN_Membership_Double_Tagged_Subscriber_Traffic
    [Documentation]    1	Subscriber Side VLAN Membership Double Tagged Subscriber Traffic: Create service with target tag-action. The outermost VLAN is enabled for DHCP Relay. Force a client to obtain a dynamic address. Display DHCP Snoop table. -> The Subscriber fails to obtain an address. Tag depth not supported.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-740    @globalid=2307084    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Subscriber Side VLAN Membership Double Tagged Subscriber Traffic: Create service with target tag-action. The outermost VLAN is enabled for DHCP Relay. Force a client to obtain a dynamic address. Display DHCP Snoop table. -> The Subscriber fails to obtain an address. Tag depth not supported. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=${lease_time}    ovlan_pbit=${stag_pbit}    ivlan_pbit=${ctag_pbit}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan_2}    ovlan_pbit=${Qtag_pbit}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    stop_capture    tg1    service_p1
    save_and_analyze_packet_on_port    tg1    service_p1    bootp.dhcp==1 and (vlan.priority==${stag_pbit} and vlan.etype==0x8100) and (vlan.priority==${ctag_pbit} and vlan.etype==0x800)
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    configuration of service
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}    set-cevlan-pcp=${ctag_pbit}    set-stag-pcp=${stag_pbit}

case teardown
    [Documentation]    case teardown

    [Arguments]
    log    STC related action
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan=${ctag_vlan}