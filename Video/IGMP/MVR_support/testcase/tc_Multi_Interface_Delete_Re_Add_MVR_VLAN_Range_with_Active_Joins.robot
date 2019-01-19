*** Settings ***
Documentation     Multi Interface Delete/Re-Add MVR VLAN Range with Active Joins
Resource          ./base.robot


*** Variables ***
${max_igmp_host}    4

*** Test Cases ***
tc_Multi_Interface_Delete_Re_Add_MVR_VLAN_Range_with_Active_Joins
    [Documentation]    1	Create video service with same MVR profile on two access interfaces with at least two ranges. Proxy IGMP mode in use. 			
    ...    2	Join a range of video streams on both ports. 	Both ports are join the same range of video streams. 		
    ...    3	Actively join a range of streams including those part of the deny filter and all of the allowed ranges. 	When the range is present streams associated with the range and other provisioned ranges are forwarded.		
    ...    4	Remove one of the ranges from the profile. 	When a range is removed only the streams associated with the removed range are stopped. 		
    ...    5	Re-add the range.	When the range is re-added the streams associated with the range are again forwarded. 
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1497    @globalid=2321566    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Create video service with same MVR profile on two access interfaces with at least two ranges. Proxy IGMP mode in use.
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    subscriber_point_check_status_up    subscriber_point2   

    log    STEP:2 Join a range of video streams on both ports. Both ports are join the same range of video streams.
    log    create igmp host1,2 for range1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    create_igmp_host    tg1    igmp_host2    subscriber_p1    v2    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]    
    log    create igmp host3,4 for range2
    create_igmp_host    tg1    igmp_host3    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_name=mc_group2    mc_group_start_ip=@{p_mvr_start_ip_list}[1]  
    create_igmp_host    tg1    igmp_host4    subscriber_p1    v2    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_name=mc_group2    mc_group_start_ip=@{p_mvr_start_ip_list}[1]  
    
    log    igmp host join
    : FOR    ${index}    IN RANGE    1    ${max_igmp_host}+1
    \    tg control igmp    tg1    igmp_host${index}    join
    log    sleep for igmp join
    sleep    5s
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_network_list}[0].${index}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    @{p_video_vlan_list}[1]    @{p_mvr_network_list}[1].${index}
    
    log    get mcast_group and video_vlan Dictionary for range1
    ${dict_group_vlan1}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Set To Dictionary    ${dict_group_vlan1}    @{p_mvr_network_list}[0].${index}=@{p_video_vlan_list}[0]
    
    log    get mcast_group and video_vlan Dictionary for range1 and range2
    ${dict_group_vlan2}    Copy Dictionary    ${dict_group_vlan1}
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Set To Dictionary    ${dict_group_vlan2}    @{p_mvr_network_list}[1].${index}=@{p_video_vlan_list}[1]
    
    log    check igmp multicast vlan for range1 and range2
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan2}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan2}

    log    STEP:3 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mc_group1    igmp_querier0    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic2    service_p1    mc_group2    igmp_querier1    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1

    log    STEP:4 Remove one of the ranges from the profile. When a range is removed only the streams associated with the removed range are stopped.
    dprov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[1]    @{p_mvr_end_ip_list}[1]    @{p_video_vlan_list}[1]
    log    igmp host join
    tg control igmp    tg1    igmp_host3    leave
    tg control igmp    tg1    igmp_host3    join
    tg control igmp    tg1    igmp_host4    leave
    tg control igmp    tg1    igmp_host4    join
    log    sleep for igmp join
    sleep    5s
    log    check igmp multicast group contain range1, not contain range2
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_network_list}[0].${index}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    @{p_video_vlan_list}[1]    @{p_mvr_network_list}[1].${index}    no
    
    log    check igmp multicast vlan for range1
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan1}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan1}
    
    log    send traffic and verify only the streams associated with the removed range2 are stopped, streams for range1 still pass
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep for traffic stop
    sleep    ${p_traffic_stop_time}
    log    verify only the streams associated with the removed range2 are stopped
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic2
    log    verify streams for range1 still pass
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic1    ${p_traffic_loss_rate} 

    log    STEP:5 Re-add the range. When the range is re-added the streams associated with the range are again forwarded.
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[1]    @{p_mvr_end_ip_list}[1]    @{p_video_vlan_list}[1]
    tg control igmp    tg1    igmp_host3    leave
    tg control igmp    tg1    igmp_host3    join
    tg control igmp    tg1    igmp_host4    leave
    tg control igmp    tg1    igmp_host4    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_network_list}[0].${index}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    @{p_video_vlan_list}[1]    @{p_mvr_network_list}[1].${index}
    
    log    check igmp multicast vlan for range1 and range2
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan2}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan2}
    
    log    send multicast downstream traffic and verify no drop packet
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    : FOR    ${index}    IN RANGE    1    ${max_igmp_host}+1
    \    tg control igmp    tg1    igmp_host${index}    leave
    \    tg delete igmp    tg1    igmp_host${index}
