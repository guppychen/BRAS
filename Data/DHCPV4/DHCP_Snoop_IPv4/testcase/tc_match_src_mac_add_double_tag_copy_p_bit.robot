*** Settings ***
Documentation     match src-mac(only support untag packets) add double tag copy p-bit
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_match_src_mac_add_double_tag_copy_p_bit
    [Documentation]    1	configure svc with match src-mac add double tag copy p-bit	success
    ...    2	start dhcp and capture packets	can get dhcp lease; p-bit is correct in packets
    ...    3	run dhcp bounded traffic	traffic can flow
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2054    @globalid=2334101    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 configure svc with match src-mac add double tag copy p-bit success
    prov_class_map    eutA    ${class_map_name}    ethernet    flow     1    1    src-mac=${client_mac}     
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    flow     1    add-cevlan-tag=${ctag_vlan}    set-ctag-pcp=promote    set-stag-pcp=promote
    subscriber_point_add_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    log    STEP:2 start dhcp and capture packets can get dhcp lease; p-bit is correct in packets
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    stop_capture    tg1    service_p1
    save_and_analyze_packet_on_port    tg1    service_p1    bootp.dhcp==1 and (vlan.priority==0 and vlan.etype==0x8100) and (vlan.priority==0 and vlan.etype==0x800)
    log    STEP:3 run dhcp bounded traffic traffic can flow
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
    log      add service

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
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name}