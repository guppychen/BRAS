*** Settings ***
Documentation     Modify IGMP profile
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${igmp_prf_new}    auto_new_igmp_prf
${exp_query_cnt}   3

*** Test Cases ***
tc_Layer3_Applications_Video_Modify_IGMP_profile
    [Documentation]    1	Configure an IGMP profile "X" and apply it to the service profile	Configuration successful		
    ...    2	Join and leave channels and make sure IGMP profile parameters are working as configured (Ex. General Query Interval Time)	Configuration Successful		
    ...    3	Configure an IGMP profile "Y" and change the default General Query Interval value and apply it to the same subscriber above	Subsribers are able to Join		
    ...    4	Join and leave channels and capture the General Queries received at the subscriber end make sure query interval is as configured in the IGMP profile	Subscribers not able to join
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1469    @globalid=2321538    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    log    STEP:1 Configure an IGMP profile "X" and apply it to the service profile Configuration successful (This step is done with ${p_igmp_prf} in init file)
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=${p_gen_query_invl1}    startup-query-interval=${p_startup_query_invl}    startup-query-count=${p_startup_query_cnt}
    ${query_second}    evaluate    (${p_gen_query_invl1}/10)*${exp_query_cnt}
    ${startup_query_wait}    evaluate    (${p_startup_query_invl}/10)*${p_startup_query_cnt}+10
    prov_vlan    eutA    ${mvr_vlan}    igmp-profile=${p_igmp_prf}
    prov_vlan    eutA    ${p_data_vlan}    igmp-profile=${p_igmp_prf}
    log    sleep for cli operation response
    sleep    10s

    log    STEP:2 Join and leave channels and make sure IGMP profile parameters are working as configured (Ex. General Query Interval Time) Configuration Successful
    tg control igmp    tg1    igmp_host    join
    log    sleep for startup_GQ timer timeout
    sleep    ${startup_query_wait}
    start_capture    tg1    subscriber_p1
    log    sleep for general-query timer1 works
    sleep    ${query_second}
    stop_capture    tg1    subscriber_p1
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}
    
    log    save captured file and analyze
    ${save_file_mvr}    set variable    ${p_tg_store_file_path}/${TEST NAME}_1.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_mvr}
    log    save captured packets to ${save_file_mvr}
    sleep    10s
    log    analyze igmp packet for General Query Interval Time
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file_mvr}
    ...    ((igmp) && (igmp.version == 2) && (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))
    # should be true    (${pkt_cnt}==${exp_query_cnt}) or (${pkt_cnt}==${exp_query_cnt}+1) 
    should be true    0<=(${pkt_cnt}-${exp_query_cnt})<=1
    tg control igmp    tg1    igmp_host    leave

    log    STEP:3 Configure an IGMP profile "Y" and change the default General Query Interval value and apply it to the same subscriber above Subsribers are able to Join
    prov_igmp_profile    eutA    ${igmp_prf_new}    general-query-interval=${p_gen_query_invl2}    startup-query-interval=${p_startup_query_invl}    startup-query-count=${p_startup_query_cnt}
    ${query_second}    evaluate    (${p_gen_query_invl2}/10)*${exp_query_cnt}
    prov_vlan    eutA    ${mvr_vlan}    igmp-profile=${igmp_prf_new}
    prov_vlan    eutA    ${p_data_vlan}    igmp-profile=${igmp_prf_new}
    log    sleep for cli operation response
    sleep    10s

    log    STEP:4 Join and leave channels and capture the General Queries received at the subscriber end make sure query interval is as configured in the IGMP profile Subscribers not able to join
    tg control igmp    tg1    igmp_host    join
    log    sleep for startup_GQ timer timeout
    sleep    ${startup_query_wait}
    start_capture    tg1    subscriber_p1
    log    sleep for general-query timer2 works
    sleep    ${query_second}
    stop_capture    tg1    subscriber_p1
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}
    
    log    save captured file and analyze
    ${save_file_mvr}    set variable    ${p_tg_store_file_path}/${TEST NAME}_2.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_mvr}
    log    save captured packets to ${save_file_mvr}
    sleep    10s
    log    analyze igmp packet for General Query Interval Time
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file_mvr}
    ...    ((igmp) && (igmp.version == 2) && (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))
    should be true    0<=(${pkt_cnt}-${exp_query_cnt})<=1

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    
    log    subscriber side provision
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    rollback igmp profile provision the same as init file mvr_suite_provision
    dprov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval
    prov_vlan    eutA    ${mvr_vlan}    igmp-profile=${p_igmp_prf}
    dprov_vlan    eutA    ${p_data_vlan}    igmp-profile
    delete_config_object    eutA    igmp-profile    ${igmp_prf_new}

    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host