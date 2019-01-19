*** Settings ***
Documentation    Multiple MVR Service with Max Profiles with Unique VLANs
Resource     ./base.robot

*** Variables ***
${sub_num}    2


*** Test Cases ***
tc_Multiple_MVR_Service_with_Max_Profiles_with_Unique_VLANs
    [Documentation]
    ...    1	Provision 2 mcast-profiles with each referencing a unique MVR VLAN and a unique mcast-range. IGMP proxy mode is used.			
    ...    2	Create unique service 2 access interfaces each referencing a unqiue mcast-profiles.			
    ...    3	Create one multicast stream per MVR range. On each access interface attempt to join all created streams.	Streams are forwarded only if the line is associated with the MVR VLAN. All other streams not forwarded. Each interface is allowed to join a unique stream.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1541      @subFeature=MVR support      @globalid=2321610      @priority=P2      @user_interface=CLI    @eut=NGPON2-4  
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Provision 2 mcast-profiles with each referencing a unique MVR VLAN and a unique mcast-range. IGMP proxy mode is used. 
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    prov_mvr_profile    eutA    auto_mvr_prf${index}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    \    prov_multicast_profile    eutA    auto_mcast_prf${index}     auto_mvr_prf${index}     ${p_mcast_max_stream}

    log    STEP:2 Create unique service 2 access interfaces each referencing a unqiue mcast-profiles. 
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=auto_mcast_prf0
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=auto_mcast_prf1   cfg_prefix=sub2

    log    STEP:3 Create one multicast stream per MVR range. On each access interface attempt to join all created streams. Streams are forwarded only if the line is associated with the MVR VLAN. All other streams not forwarded. Each interface is allowed to join a unique stream. 
    log    create igmp host for subscriber_point1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp2    @{p_mvr_start_ip_list}[1]
    
    log    create igmp host for subscriber_point2
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_one_multicast_group_to_igmp_host    tg1    igmp_host2    mc_grp2    @{p_mvr_start_ip_list}[1]

    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    log    check igmp multicast summary for subscriber_point1
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1
    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1
    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[1]    @{p_video_vlan_list}[1]    contain=no

    log    check igmp multicast summary for subscriber_point2
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2
    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]    contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2
    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[1]    @{p_video_vlan_list}[1]
    
    log    create mcast bound traffic
    create_bound_traffic_udp    tg1    ds_mc_traffic_01    service_p1    mc_grp1    igmp_querier0    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_02    service_p1    mc_grp2    igmp_querier0    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_11    service_p1    mc_grp1    igmp_querier1    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_12    service_p1    mc_grp2    igmp_querier1    ${p_mc_traffic_rate_mbps}
    
    log    send and check downstream mcast traffic
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${p_traffic_run_time}    Wait ${p_traffic_run_time} for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${p_traffic_stop_time}    Wait ${p_traffic_stop_time} for traffic stop
    
    log    verify traffic group 01, 12 traffics fully passed
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_01    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_12    ${p_traffic_loss_rate} 
    log    verify traffic group 02, 11 traffics fully lost
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_02
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_11
    
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2
    
    log    create IGMP querier and check
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=auto_mcast_prf0
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=auto_mcast_prf1   cfg_prefix=sub2

    log    delete multicast profile and mvr profile
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    delete_config_object    eutA    multicast-profile    auto_mcast_prf${index}
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf${index} 
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${sub_num}
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
