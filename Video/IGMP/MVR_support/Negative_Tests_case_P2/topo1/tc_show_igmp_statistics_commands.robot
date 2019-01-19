*** Settings ***
Documentation    Displaying show igmp statistics commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mc_start_ip}    @{p_mvr_start_ip_list}[0]

*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_statistics_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Configure STC port with IGMP quirier and send multicast streams	Configuration successful		
    ...    3	Join multicast groups from the provisioned subscribers	Verify that subscriber able to receive multicast stream		
    ...    4	Issue the command "show igmp statistics interface ethernet "	Verify correct output is displayed		
    ...    5	Issue the command "show igmp statistics summary"	Verify correct output is displayed		
    ...    6	Issue the command "show igmp statistics vlan "	Verify correct output is displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3487      @subFeature=MVR support      @globalid=2478942      @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Configure Video Service on UNI port Configuration successful 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    clear igmp statistics
    clear_igmp_statistics    eutA    all
    
    log    capture igmp packet
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    log    Wait for prepare capture
    sleep    10s    Wait for prepare capture
    
    log    STEP:2 Configure STC port with IGMP quirier and send multicast streams Configuration successful 
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    STEP:3 Join multicast groups from the provisioned subscribers Verify that subscriber able to receive multicast stream 
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_start_ip}    ${mvr_vlan}
    
    log    igmp host leave and check
    tg control igmp    tg1    igmp_host1    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_start_ip}    ${mvr_vlan}    contain=no
    
    log    stop capture and save packet
    tg control igmp querier by name    tg1    igmp_querier    stop
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    
    log    get show igmp statistics info
    ${stat_sum}    check_igmp_statistics    eutA    summary
    ${stat_mvr_vlan}    check_igmp_statistics    eutA    vlan    ${mvr_vlan}
    ${stat_svlan}    check_igmp_statistics    eutA    vlan    ${p_data_vlan}
    
    log    save packet
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}
    sleep    10s
    
    log    analyze service_p1 packet
    log    get tg send general query count
    ${tg_gen_query}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${mvr_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    
    log    get tg send group query count
    ${tg_grp_query}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${mvr_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${mc_start_ip})
    
    log    get device send report count
    ${eut_report}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${mvr_vlan}) && (ip.src == @{p_proxy.ip}[0])
    
    log    get device send leave count
    ${eut_leave}    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${mvr_vlan}) && (ip.src == @{p_proxy.ip}[0])
    
    log    analyze subscriber_p1 packet
    log    get device send general query count
    Wsk Load File    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    ${eut_gen_query}    wsk_get_total_packet_count
    
    log    get device send group query count
    ${eut_grp_query}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${mc_start_ip})
    
    log    get tg send report count
    ${tg_report}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_host.ip})
    
    log    get tg send leave count
    ${tg_leave}    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_host.ip})

    log    STEP:4 Issue the command "show igmp statistics interface ethernet " Verify correct output is displayed (According to EXA-18133, this feature doesn't support) 

    log    STEP:5 Issue the command "show igmp statistics summary" Verify correct output is displayed 
    check_cmd_result    ${stat_sum}
    ...    rx-reports=${tg_report}    rx-leaves=${tg_leave}    rx-general-queries=${tg_gen_query}    rx-group-queries=${tg_grp_query}
    ...    tx-reports=${eut_report}    tx-leaves=${eut_leave}    tx-general-queries=${eut_gen_query}    tx-group-queries=${eut_grp_query}

    log    STEP:6 Issue the command "show igmp statistics vlan " Verify correct output is displayed
    check_cmd_result    ${stat_svlan}    rx-reports=${tg_report}    rx-leaves=${tg_leave}
    check_cmd_result    ${stat_mvr_vlan}
    ...    rx-general-queries=${tg_gen_query}    rx-group-queries=${tg_grp_query}
    ...    tx-reports=${eut_report}    tx-leaves=${eut_leave}    tx-general-queries=${eut_gen_query}    tx-group-queries=${eut_grp_query}

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    log    remove igmp profile from not used mvr vlan to prevent redundancy packet
    ${not_use_video_vlan}    Copy List    ${p_video_vlan_list}
    Remove From List    ${not_use_video_vlan}    0
    : FOR    ${vlan}    IN    @{not_use_video_vlan}
    \    dprov_vlan    eutA    ${vlan}    igmp-profile
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_start_ip=${mc_start_ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    recover igmp profile for all mvr vlan
    : FOR    ${vlan}    IN    @{p_video_vlan_list}
    \    prov_vlan    eutA    ${vlan}    igmp-profile=${p_igmp_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1