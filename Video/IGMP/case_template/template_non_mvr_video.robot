*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***
${video_vlan}    @{p_video_vlan_list}[0]

*** Keywords ***
template_non_mvr_video
    [Arguments]    ${version}    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_type}=${EMPTY}    ${ring_service_point_list}=${EMPTY}
    [Tags]       @author=CindyGao
    [Teardown]   non_mvr_template_teardown    ${subscriber_point}
    log    case setup: subscriber side provision
    set test variable    ${subscriber_eut}    ${service_model.${subscriber_point}.device}
    set test variable    ${uplink_eth_point}    @{service_model.${uplink_eth_service_point_list}}[0]    
    
    log    STEP:1 create multicast profile and add to subscriber_point
    prov_multicast_profile    ${subscriber_eut}    ${p_mcast_prf}    max-streams=${p_mcast_max_stream}    
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    ${subscriber_point}    ${p_match_vlan}    ${video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}  
    
    log    check node status
    subscriber_point_check_status_up    ${subscriber_point}
    service_point_list_check_status_up    ${uplink_eth_service_point_list}
    Run Keyword If    '${EMPTY}'!='${ring_type}'    service_point_list_check_status_up    ${ring_service_point_list}

    log    STEP:2 Configure STC port with IGMP quirier
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start

    log    check igmp querier
    Run Keyword If    '${EMPTY}'!='${ring_type}'    check_igmp_querier_non_mvr    ${ring_service_point_list}    ${version}
    ...    ELSE    check_igmp_querier_non_mvr    ${uplink_eth_service_point_list}    ${version}

    log    STEP:3 Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    &{dict_name}    create_igmp_host    tg1    igmp_host    subscriber_p1    ${version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    log    sleep for igmp join
    sleep    5s
    
    log    STEP:4 check igmp multicast group on subscriber connected device
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    ${subscriber_point}    ${video_vlan}    @{p_mvr_start_ip_list}[0]
    Run Keyword If    '${EMPTY}'!='${ring_type}'    check_non_mvr_igmp_multicast_group_on_ring_node    ${ring_type}    ${ring_service_point_list}
    
    log    STEP:5 save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    10s
    log    analyze igmp packet
    Run Keyword If    "v2"=="${version}"    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (igmp.version == 2) && (vlan.id == ${video_vlan})) && (ip.dst == @{p_mvr_start_ip_list}[0])
    ...    ELSE IF    "v3"=="${version}"    analyze_packet_count_greater_than    ${save_file}    ((igmp) && (igmp.version == 3) && (vlan.id == ${video_vlan})) && (ip.dst == ${igmpv3_report_dst_ip})
    
    log    STEP:6 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic    service_p1    &{dict_name}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}
