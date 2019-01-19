*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Multple_video_vlan
    [Documentation]    1	One video vlan config as v2 and other config as v3.	Both video vlan subscriber works fine with operation mode v2 and v3 for each of them.
    ...    2	All the video vlan config as "auto mode"; connect V2 mrouter for one video vlan and v3 mrouter for another video vlan	One video vlan has operation mode as v2 and other has v3. Both video flowing on their video subscriber.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2248    @GlobalID=2346515
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 One video vlan config as v2 and other config as v3. Both video vlan subscriber works fine with operation mode v2 and v3 for each of them.

    log    STEP:2 All the video vlan config as "auto mode"; connect V2 mrouter for one video vlan and v3 mrouter for another video vlan One video vlan has operation mode as v2 and other has v3. Both video flowing on their video subscriber.

#    set test variable    ${subscriber_eut}    ${service_model.subscriber_point1.device}
    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    create_igmp_querier    tg1    igmp_querier2    service_p1    v3    ${p_igmp_querier2.mac}    ${p_igmp_querier2.ip}    ${p_igmp_querier2.gateway}    @{p_video_vlan_list}[1]
    tg control igmp querier by name    tg1    igmp_querier1    start
    tg control igmp querier by name    tg1    igmp_querier2    start

    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V2
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[1]    @{p_proxy_2.ip}[0]    ${p_igmp_querier2.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[1]    subscriber_point2    V3    @{p_proxy_2.ip}[0]


    log    Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v2    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    create_igmp_host    tg1    igmp_host2    subscriber_p1    v3    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_host2.gateway}    ${p_match_vlan_switch2}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    sleep    ${wait_igmp_client_join_leave}

    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[1]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point2.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[1]



    log    save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2248.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (igmp.version == 2) && (vlan.id == @{p_video_vlan_list}[0])) && (ip.dst == @{p_mvr_start_ip_list}[0])
    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (igmp.version == 3) && (vlan.id == @{p_video_vlan_list}[1])) && (ip.dst == 224.0.0.22)


    log    send multicast downstream traffic
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mcast_group    igmp_querier1    10
    create_bound_traffic_udp    tg1    ds_mc_traffic2    service_p1    mcast_group    igmp_querier2    10
    Tg Control Traffic    tg1    ds_mc_traffic1    run
    Tg Control Traffic    tg1    ds_mc_traffic2    run
    sleep    ${run_traffic_time}
    Tg Control Traffic    tg1    ds_mc_traffic1    stop
    Tg Control Traffic    tg1    ds_mc_traffic2    stop
    sleep    ${wait_to_save_file}
    ${dict_loss1}    Tg Get Traffic Stats By Key On Stream    tg1    ds_mc_traffic1    rx.dropped_pkts
    ${dict_loss2}    Tg Get Traffic Stats By Key On Stream    tg1    ds_mc_traffic2    rx.dropped_pkts
    ${list_loss1}    Get Dictionary Values    ${dict_loss1}
    ${list_loss2}    Get Dictionary Values    ${dict_loss2}
    Should Be Equal As Integers   @{list_loss1}[0]    0
    Should Be Equal As Integers   @{list_loss2}[0]    0


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2248 setup
    log    set up one video vlan to V2 mode and other video vlan to V3 mode
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V2
    prov_igmp_profile    eutA    ${p_igmp_profile2}    V3


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2248 teardown
    prov_igmp_profile    eutA    ${p_igmp_profile1}    AUTO
    prov_igmp_profile    eutA    ${p_igmp_profile2}    AUTO
    tg control igmp    tg1    igmp_host1    leave
    tg control igmp    tg1    igmp_host2    leave
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg control igmp querier by name    tg1    igmp_querier2    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg delete igmp querier    tg1    igmp_querier2
    tg delete igmp    tg1    igmp_host1
    tg delete igmp    tg1    igmp_host2
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}