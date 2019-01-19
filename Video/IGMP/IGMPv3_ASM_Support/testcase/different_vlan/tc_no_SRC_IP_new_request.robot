*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_no_SRC_IP_new_request
    [Documentation]    1	New Request: V3 report: SRC IP = none	report is treated as an ASM join.
    ...    2	For a channel which is currently joined	confirm the ASM IS_EXCL and ASM TO_IN is se
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2288    @GlobalID=2346555
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 New Request: V3 report: SRC IP = none report is treated as an ASM join.

    log    STEP:2 For a channel which is currently joined confirm the ASM IS_EXCL and ASM TO_IN is sent

    log    case setup: subscriber side provision
    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start

    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    log    Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v3    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}

    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]



    log    save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2288.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (vlan.id == @{p_video_vlan_list}[0])) && (ip.dst == 224.0.0.22)


    log    send multicast downstream traffic
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mcast_group    igmp_querier1    10
    Tg Control Traffic    tg1    ds_mc_traffic1    run
    sleep    ${run_traffic_time}
    Tg Control Traffic    tg1    ds_mc_traffic1    stop
    sleep    ${wait_to_save_file}
    ${dict_loss1}    Tg Get Traffic Stats By Key On Stream    tg1    ds_mc_traffic1    rx.dropped_pkts
    ${list_loss1}    Get Dictionary Values    ${dict_loss1}
    Should Be Equal As Integers   @{list_loss1}[0]    0

    log    re-join the channel
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v3    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}
    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2288_1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (vlan.id == @{p_video_vlan_list}[0])) && (ip.dst == 224.0.0.22)


    log    send multicast downstream traffic
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mcast_group    igmp_querier1    10
    Tg Control Traffic    tg1    ds_mc_traffic1    run
    sleep    ${run_traffic_time}
    Tg Control Traffic    tg1    ds_mc_traffic1    stop
    sleep    ${wait_to_save_file}
    ${dict_loss1}    Tg Get Traffic Stats By Key On Stream    tg1    ds_mc_traffic1    rx.dropped_pkts
    ${list_loss1}    Get Dictionary Values    ${dict_loss1}
    Should Be Equal As Integers   @{list_loss1}[0]    0



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2288 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2288 teardown
    tg control igmp    tg1    igmp_host1    leave
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg delete igmp    tg1    igmp_host1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}