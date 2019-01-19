*** Settings ***
Documentation    MVR Multicast Video with Unicast Video simultaneously (Subscriber untagged)
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_MVR_Multicast_Video_with_Unicast_Video_simultaneously_Subscriber_untagged
    [Documentation]
    ...    1	Add basic video service to ONT/xDSL line. (Subscriber untagged)			
    ...    2	Generate bidirectional unicast traffic at some rate lower than the bw-profile.			
    ...    3	Join a multicast channel that makes total bw forwarded downstream slightly lower than the bw-profile.	Both the bi-directional unicast traffic and the downstream multicast stream are forwarded with no losses.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1528      @subFeature=MVR support      @globalid=2321597      @priority=P2      @user_interface=CLI    @eut=NGPON2-4
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Add basic video service to ONT/xDSL line. (Subscriber untagged) 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan}    mcast_profile=${p_mcast_prf}

    log    STEP:2 Generate bidirectional unicast traffic at some rate lower than the bw-profile. 
    create_dhcp_server    tg1    dhcps    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.pool_start}    ${p_data_vlan}
    create_dhcp_client    tg1    dhcpc    subscriber_p1    dhcpc_group    ${p_dhcp_client.mac}
    Tg Control Dhcp Server    tg1    dhcps    start
    Tg Control Dhcp Client    tg1    dhcpc_group    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${p_lease_negotiated_time}
    stop_capture    tg1    service_p1
    create_bound_traffic_udp    tg1    us_data_traffic    subscriber_p1    dhcps    dhcpc_group    ${p_us_data_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_data_traffic    service_p1    dhcpc_group    dhcps    ${p_ds_data_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1

    log    STEP:3 Join a multicast channel that makes total bw forwarded downstream slightly lower than the bw-profile. Both the bi-directional unicast traffic and the downstream multicast stream are forwarded with no losses. 
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    session=${p_igmp_group_session_num}    mc_group_name=mc_grp    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host    join
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}
    sleep    ${p_traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${p_traffic_stop_time}    Wait for traffic stop
    Tg Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}
    
    log    create bound mcast traffic
    create_bound_traffic_udp    tg1    ds_mc_traffic    service_p1    mc_grp    igmp_querier    ${p_mc_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1    
    sleep    ${p_traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${p_traffic_stop_time}    Wait for traffic stop
    Tg Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}
    
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host    
    delete_tg_dhcp_session    tg1    dhcps    dhcpc    dhcpc_group
    Tg Delete All Traffic    tg1
