*** Settings ***
Documentation    Multiple MVR Service with Max MVR VLANs
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Multiple_MVR_Service_with_Max_MVR_VLANs
    [Documentation]
    ...    1	Provision a mcast-profile with max MVR VLANs. Each MVR VLAN references a unique mcast-range.		max mvr vlan number is 8 for AXOS	
    ...    2	Provision MVR video service on 2 access interfaces. IGMP proxy mode is used.			
    ...    3	Create one multicast stream per MVR range. On each line attempt to join all created streams.	All streams are forwarded.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1543      @subFeature=MVR support      @globalid=2321612      @priority=P2      @user_interface=CLI    @eut=NGPON2-4
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Provision a mcast-profile with max MVR VLANs. Each MVR VLAN references a unique mcast-range. max mvr vlan number is 8 for AXOS
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:2 Provision MVR video service on 2 access interfaces. IGMP proxy mode is used. 
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    STEP:3 Create one multicast stream per MVR range. On each line attempt to join all created streams. All streams are forwarded. 
    log    create igmp host for subscriber_point1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_multicast_group_to_igmp_host    tg1    igmp_host1    ${p_max_mvr_vlan_prov_limit}    1    ${p_mvr_start_ip_list}    mc_grp_prefix=mc_grp_sub1
    
    log    create igmp host for subscriber_point2
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_multicast_group_to_igmp_host    tg1    igmp_host2    ${p_max_mvr_vlan_prov_limit}    1    ${p_mvr_start_ip_list}    mc_grp_prefix=mc_grp_sub2
    
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    log    check igmp multicast summary for subscriber_point1
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1
    \    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    
    log    check igmp multicast summary for subscriber_point2
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2
    \    ...    ${p_data_vlan}    @{p_mvr_start_ip_list}[${index}]    @{p_video_vlan_list}[${index}]

    log    create mcast bound traffic
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    create_bound_traffic_udp    tg1    ds_mc_traffic_1${index}    service_p1    mc_grp_sub1_${index}    igmp_querier${index}    ${p_mc_traffic_rate_mbps}
    \    create_bound_traffic_udp    tg1    ds_mc_traffic_2${index}    service_p1    mc_grp_sub2_${index}    igmp_querier${index}    ${p_mc_traffic_rate_mbps}
    
    log    send and check downstream mcast traffic
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${p_traffic_run_time}    Wait ${p_traffic_run_time} for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${p_traffic_stop_time}    Wait ${p_traffic_stop_time} for traffic stop
    Tg Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}
    
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2
    
    log    create IGMP querier and check
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
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
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_prov_limit}
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
