*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Multiple_vlan_MVR_in_V2_mode
    [Documentation]    1	Change the only one v2 mode vlan to v3.	the video can not work on the vlan
    ...    2	Delete the only one V2 vlan from the MVR profile	the video can not work on the vlan
    ...    3	Change the only one V2 mode vlan to auto mode	video flow fine on the vlan with v2 subscriber
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2264    @GlobalID=2346531
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Change the only one v2 mode vlan to v3. the video can not work on the vlan

    log    STEP:2 Delete the only one V2 vlan from the MVR profile the video can not work on the vlan

    log    STEP:3 Change the only one V2 mode vlan to auto mode video flow fine on the vlan with v2 subscriber

    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    log    Change the only one v2 mode vlan to v3. the video can not work on the vlan
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    sleep    ${wait_igmp_client_join_leave}
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V3
    tg control igmp querier by name    tg1    igmp_querier1    start
    log    check igmp querier on uplink eth device
    check_igmp_routers_sumarry_not_contain    eutA    @{p_video_vlan_list}[0]    ${service_model.service_point1.member.interface1}    V2    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    create_igmp_host    tg1    igmp_host1    subscriber_p1    v2    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}
    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    @{service_model.subscriber_point1.attribute.pon_port}[0]
    check_igmp_multicast_summary_not_contain    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]
    prov_igmp_profile    eutA    ${p_igmp_profile1}    auto
    tg control igmp    tg1    igmp_host1    leave

    log    delete the vlan from mvr profile
    tg control igmp querier by name    tg1    igmp_querier1    stop
    dprov_mvr_profile    eutA    ${p_mvr_prf1}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start
    sleep    ${wait_igmp_client_join_leave}
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}
    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    @{service_model.subscriber_point1.attribute.pon_port}[0]
    check_igmp_multicast_summary_not_contain    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]
    prov_mvr_profile    eutA    ${p_mvr_prf1}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[0]
    tg control igmp    tg1    igmp_host1    leave

    log    change the mvr vlan igmp mode to auto the video can work fine ticket EXA-22348
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg control igmp querier by name    tg1    igmp_querier1    start
    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V2
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]

    log    Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}

    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2264.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (vlan.id == @{p_video_vlan_list}[0])) && (ip.dst == @{p_mvr_start_ip_list}[0])


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
    log    Enter AXOS_E72_PARENT-TC-2264 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2264 teardown
    prov_igmp_profile    eutA    ${p_igmp_profile1}    AUTO
    prov_mvr_profile    eutA    ${p_mvr_prf1}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[0]
    tg control igmp    tg1    igmp_host1    leave
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg delete igmp    tg1    igmp_host1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}

