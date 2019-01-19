*** Settings ***
Documentation     Set/Unset/Set MVR Profile Association in Mcast-Profile
...    Note: The NGPON2-4 can flood the multicast stream even without igmp group on E7.
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mvr_start_ip}    @{p_mvr_start_ip_list}[0]
${mvr_end_ip}    @{p_mvr_end_ip_list}[0]


*** Test Cases ***
tc_Set_Unset_MVR_Profile_Association_in_Mcast_Profile
    [Documentation]    1	Add MVR Service to an access interface. Proxy IGMP mode in use. 		
    ...    2	Join a sampling of streams. 	Stream sampling successfully obtained when MVR profile is present in mcast-profile.	
    ...    3	Remove MVR profile from mcast profile. 	When MVR profile is removed from mcast profile streams are stopped.	
    ...    4	Re-add MVR profile to mcast profile. 	Stream sampling successfully obtained when MVR profile is present in mcast-profile.	
    ...    Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL, 
    ...    GPON scripts should provision bw-profile < total multicast bandwidth required 
    ...    and DSL scripts should be provisioned with => total multicast bandwidth required.
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1493    @globalid=2321562    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Add MVR Service to an access interface. Proxy IGMP mode in use.
    log    create mvr profile
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${mvr_start_ip}    ${mvr_end_ip}    ${mvr_vlan}
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    log    subscriber point add svc
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Join a sampling of streams. Stream sampling successfully obtained when MVR profile is present in mcast-profile.
    &{dict_name}    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=${mvr_start_ip}
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    tg control igmp    tg1    igmp_host    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_mc_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_mc_ip}
    
    log    create mcast traffic and check packet loss
    create_bound_traffic_udp    tg1    ds_mc_traffic    service_p1    &{dict_name}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1
    # tg control igmp    tg1    igmp_host    leave

    log    STEP:3 Remove MVR profile from mcast profile. When MVR profile is removed from mcast profile streams are stopped.
    dprov_multicast_profile    eutA    ${p_mcast_prf}    mvr-profile
    tg control igmp    tg1    igmp_host    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_mc_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_mc_ip}    no

    log    send multicast downstream traffic all loss
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep for traffic stop
    sleep    ${p_traffic_stop_time}
    log    verify all downstream multicast packet loss
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic

    tg control igmp    tg1    igmp_host    leave
    
    log    STEP:4 Re-add MVR profile to mcast profile. Stream sampling successfully obtained when MVR profile is present in mcast-profile.
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}
    tg control igmp    tg1    igmp_host    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_mc_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_mc_ip}
    
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host

