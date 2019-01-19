*** Settings ***
Documentation    MVR Video with IGMP Proxy (Add Tag Match All OUI Filtered Subscriber Traffic) 
Resource     ./base.robot

*** Variables ***
${sub_num}    2
${igmp_pbit}    ${p_default_igmp_pbit}
${proxy_ip}    @{p_proxy.ip}[0]

${policy_map}    auto_def_policy_map
${class_map}    auto_def_class_map

${mvr_vlan_1}    @{p_video_vlan_list}[0]
${mc_start_ip_1}    @{p_mvr_start_ip_list}[0]
${querier_pbit_1}    7
${host_pbit_1}    0

${mvr_vlan_2}    @{p_video_vlan_list}[1]
${mc_start_ip_2}    @{p_mvr_start_ip_list}[1]
${querier_pbit_2}    6
${host_pbit_2}    0


*** Test Cases ***
tc_MVR_Video_with_IGMP_Proxy_Add_Tag_Match_All_OUI_Filtered_Subscriber_Traffic
    [Documentation]
    ...    1	Add basic MVR video service to two ONT ports. (Add Tag Match All OUI Filtered Subscriber Traffic) 	
    ...    2	Perform the following tasks capturing traffic as the receive location for each task:			
    ...    3	Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber, 
    ...         generate requested multicast streams from querier, generate leave for each associated stream from each subscriber.			
    ...    4	The following untag traffic is received at the subscriber: general IGMP queries, requested multicast streams, 
    ...         two last member group specific IGMP queries after the leave.			
    ...    5	Downstream IGMP traffic p-bit = 4. Downstream multicast stream traffic p-bit = p-bit received at uplink. 			
    ...    6	The following single tagged of the MVR VLAN with p-bit = 4 traffic is received at the querier: joins/reports and leaves.			
    ...    7	No traffic is forwarded between the two ONT ports.			
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1534      @subFeature=MVR support      @globalid=2321603      @priority=P2      @user_interface=CLI    @eut=NGPON2-4
    ...        @jira=PREM-24229
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Add basic MVR video service to two ONT ports. (Change Tag Match Single Tagged Subscriber Traffic)
    @{list_src_mac}    Split String    ${p_igmp_host.mac}    :
    prov_class_map    eutA    ${class_map}    ethernet    flow    1    1    src-oui=@{list_src_mac}[0]:@{list_src_mac}[1]:@{list_src_mac}[2]
    prov_policy_map    eutA    ${policy_map}    class-map-ethernet    ${class_map}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${policy_map}    mcast_profile=auto_mcast_prf_0
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=auto_mcast_prf_1   cfg_prefix=sub2

    log    STEP:2 Perform the following tasks capturing traffic as the receive location for each task:
    log    STEP:3 Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber,
    log    ... generate requested multicast streams from querier, generate leave for each associated stream from each subscriber. 
    @{list_video_vlan}    Create List    ${mvr_vlan_1}    ${mvr_vlan_2}
    @{list_querier_pbit}    Create List    ${querier_pbit_1}    ${querier_pbit_2}
    @{list_host_vlan}    Create List    untagged    ${p_match_vlan_sub2}
    @{list_host_pbit}    Create List    ${host_pbit_1}    ${host_pbit_2}
    @{list_host_mc_start}    Create List    ${mc_start_ip_1}    ${mc_start_ip_2}
    
    &{dic_save_file}    igmp_simulate_and_capture_packet    tg1    service_p1    subscriber_p1    ${sub_num}    ${proxy_ip}
    ...    ${p_data_vlan}    ${list_video_vlan}    ${list_querier_pbit}    ${list_host_vlan}    ${list_host_pbit}    ${list_host_mc_start}
    ${save_file_service_p1}    set variable    &{dic_save_file}[querier]
    ${save_file_subscriber_p1}    set variable    &{dic_save_file}[host]

    log    STEP:4 The following untag traffic is received at the subscriber: general IGMP queries, requested multicast streams,
    log    ... two last member group specific IGMP queries after the leave. Downstream IGMP traffic p-bit = 4. 
    log    analyze subscriber_p1 packet
    log    get device send general query with untag
    Run Keyword And Continue On Failure    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (eth.type == 0x0800) && (ip.src == ${proxy_ip}) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    Run Keyword And Continue On Failure    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan_sub2}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    
    log    get device send group query with subscriber tag value
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (eth.type == 0x0800) && (ip.src == ${proxy_ip}) && (ip.dst == ${mc_start_ip_1})
    Should Be True    ${pkt_cnt}>=2
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan_sub2}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (ip.dst == ${mc_start_ip_2})
    Should Be True    ${pkt_cnt}>=2
    
    log    STEP:5 Downstream multicast stream traffic p-bit = p-bit received at uplink. 
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (ip.proto == ${ip_protocol_udp}) && (eth.type == 0x0800) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${mc_start_ip_1})
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (ip.proto == ${ip_protocol_udp}) && (vlan.id == ${p_match_vlan_sub2}) && (vlan.priority == ${querier_pbit_2}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${mc_start_ip_2})

    log    STEP:6 The following single tagged of the MVR VLAN with p-bit = 4 traffic is received at the querier: joins/reports and leaves. 
    log    get device send report count
    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${mvr_vlan_1}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (ip.dst == ${mc_start_ip_1})
    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${mvr_vlan_2}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (ip.dst == ${mc_start_ip_2})
    
    log    get device send leave count
    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${mvr_vlan_1}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (igmp.maddr == ${mc_start_ip_1})
    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${mvr_vlan_2}) && (vlan.priority == ${igmp_pbit}) && (ip.src == ${proxy_ip}) && (igmp.maddr == ${mc_start_ip_2})

    log    STEP:7 No traffic is forwarded between the two ONT ports.
    log    not receive packet with match_vlan 1 and dst_ip 2
    Wsk Load File    ${save_file_subscriber_p1}
    ...    (eth.type == 0x0800) && (ip.dst == ${mc_start_ip_2})
    ${pkt_cnt}    wsk_get_total_packet_count
    Should Be True    0==${pkt_cnt}
    
    log    not receive packet with match_vlan 2 and dst_ip 1
    Wsk Load File    ${save_file_subscriber_p1}
    ...    (vlan.id == ${p_match_vlan_sub2}) && (ip.dst == ${mc_start_ip_1})
    ${pkt_cnt}    wsk_get_total_packet_count
    Should Be True    0==${pkt_cnt}

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2
    
    log    mvr provision
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    prov_mvr_profile    eutA    auto_mvr_prf_${index}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    \    prov_multicast_profile    eutA    auto_mcast_prf_${index}    auto_mvr_prf_${index}    ${p_mcast_max_stream}


case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${policy_map}    mcast_profile=auto_mcast_prf_0
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=auto_mcast_prf_1   cfg_prefix=sub2

    log    delete defined policy map and class map
    delete_config_object    eutA    policy-map    ${policy_map}
    delete_config_object    eutA    class-map ethernet    ${class_map}

    log    delete multicast profile and mvr profile
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    delete_config_object    eutA    multicast-profile    auto_mcast_prf_${index}
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    tg delete igmp querier    tg1    igmp_querier${index}
    \    tg control igmp    tg1    igmp_host${index}    leave
    \    tg delete igmp    tg1    igmp_host${index}
