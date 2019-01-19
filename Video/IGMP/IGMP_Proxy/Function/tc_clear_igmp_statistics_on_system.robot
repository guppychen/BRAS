*** Settings ***
Documentation     Test suite verify clear igmp statistics on system
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2

*** Test Cases ***
tc_clear_igmp_statistics_on_system
    [Documentation]       Test suite verify clear igmp statistics on vlan
    ...    1	retrieve the igmp counters	successful
    ...    2    clear the igmp counters	successful
    ...    3	retrieve the igmp counters again	statistic on system is 0
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276051    @tcid=AXOS_E72_PARENT-TC-535
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    clear igmp statistics
    clear_igmp_statistics    eutA    all
    
    log    capture igmp packet
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    log    sleep for prepare capture
    sleep    10s
    
    log   igmp querier start and check
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    log   igmp host join and check
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    
    log    igmp host leave and check
    tg control igmp    tg1    igmp_host    leave
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    
    log    stop capture and save packet
    tg control igmp querier by name    tg1    igmp_querier    stop
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    
    log    get show igmp statistics info
    ${stat_sum}    check_igmp_statistics    eutA    summary
    
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}
    sleep    10s
    
    log    analyze service_p1 packet
    log    get tg send general query count
    ${tg_gen_query}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_video_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    
    log    get tg send group query count
    ${tg_grp_query}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_video_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${p_mcast_start_ip})
    
    log    get device send report count
    ${eut_report}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0])
    
    log    get device send leave count
    ${eut_leave}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0])
    
    log    analyze subscriber_p1 packet
    log    get device send general query count
    Wsk Load File    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    ${eut_gen_query}    wsk_get_total_packet_count
    # ${eut_gen_query}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    # ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    
    log    get device send group query count
    ${eut_grp_query}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_start_ip})
    
    log    get tg send report count
    ${tg_report}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_host.ip})
    
    log    get tg send leave count
    ${tg_leave}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_host.ip})
    
    log    STEP:1 retrieve the igmp counters successful
    check_cmd_result    ${stat_sum}
    ...    rx-reports=${tg_report}    rx-leaves=${tg_leave}    rx-general-queries=${tg_gen_query}    rx-group-queries=${tg_grp_query}
    ...    tx-reports=${eut_report}    tx-leaves=${eut_leave}    tx-general-queries=${eut_gen_query}    tx-group-queries=${eut_grp_query}

    log    STEP:2 clear the igmp counters successful
    clear_igmp_statistics    eutA    all
    
    log    STEP:3 retrieve the igmp counters again, statistic on system is 0
    check_igmp_statistics    eutA    summary
    ...    rx-reports=0    rx-leaves=0    rx-general-queries=0    rx-group-queries=0
    ...    tx-reports=0    tx-leaves=0    tx-general-queries=0    tx-group-queries=0

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1 
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_start_ip=${p_mcast_start_ip}
    
case teardown
    [Documentation]    case teardown
    log    clear igmp statistics
    tg save config into file    tg1   /tmp/igmp_proxy_case1.xml
    log    save done!!
    sleep   33
    clear_igmp_statistics    eutA    all
    
    log    delete tg session
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    