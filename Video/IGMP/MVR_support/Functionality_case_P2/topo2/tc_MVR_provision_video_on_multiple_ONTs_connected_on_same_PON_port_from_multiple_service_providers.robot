*** Settings ***
Documentation     MVR: provision video on multiple ONTs connected on same PON port from multiple service providers
...    Verify they all can view same channels and different channels at the same time
Resource          ./base.robot


*** Variables ***
${mvr_vlan_1}    @{p_video_vlan_list}[0]
${mvr_vlan_2}    @{p_video_vlan_list}[1]
${mc_ip_1}    @{p_mvr_network_list}[0].1
${mc_ip_2}    @{p_mvr_network_list}[0].10
${mc_ip_3}    @{p_mvr_network_list}[0].20

*** Test Cases ***
tc_MVR_provision_video_on_multiple_ONTs_connected_on_same_PON_port_from_multiple_service_providers
    [Documentation]    MVR: provision video on multiple ONTs connected on same PON port from multiple service providers. Verify they all can view same channels and different channels at the same time
    ...    1	Create 2 MVR-vlans, create igmp profile, set MVR-vlans igmp mode proxy, version v2	Success
    ...    2	Create 2 MVR-profiles, add corresponding MVR-vlan with its own range	Success		
    ...    3	Create 2 mcast-profiles, add mcast-map and corresponding MVR-profile	Success		
    ...    4	Add eth-svc Video to 2 subscriber ports, with corresponding mcast-profile	Success		
    ...    5	Create 2 igmp severs and 2 clients in IXIA, each server and each host has 3 groups, group 1 & 2 in mcast-map and MVR-vlan 1 range, group 2 & 3 in mcast-map and MVR-vlan 2 range	Success				
    ...    6	Show mrouter in e7	Should contain sever-ip		
    ...    7	Show mcast in e7	Should contain group 1 & 2 in server-ip 1, group 2 & 3 in server-ip 2		
    ...    8	Create 6 bound traffics in IXIA, group11, 12, 13, 21, 22, 23 start traffic	group 11, 12, 22, 23 traffics fully passed, group 13, 21 traffics fully lost
    ...    9	Delete your configurations	Success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1459    @globalid=2321527    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Create 2 MVR-vlans, create igmp profile, set MVR-vlans igmp mode proxy, version v2 Success (Done in init file)

    log    STEP:2 Create 2 MVR-profiles, add corresponding MVR-vlan with its own range Success
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${mc_ip_1}    ${mc_ip_2}    ${mvr_vlan_1}
    prov_mvr_profile    eutA    mvr_prf2    ${mc_ip_2}    ${mc_ip_3}    ${mvr_vlan_2}

    log    STEP:3 Create 2 mcast-profiles, add mcast-map and corresponding MVR-profile Success
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    prov_multicast_profile    eutA    mcast_prf2    mvr_prf2    ${p_mcast_max_stream}

    log    STEP:4 Add eth-svc Video to 2 subscriber ports, with corresponding mcast-profile Success
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=mcast_prf2   cfg_prefix=sub2

    log    STEP:5 Create 2 igmp severs and 2 clients in IXIA, each server and each host has 3 groups, group 1 & 2 in mcast-map and MVR-vlan 1 range, group 2 & 3 in mcast-map and MVR-vlan 2 range Success
    create_igmp_querier    tg1    igmp_querier1    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan_1}
    create_igmp_querier    tg1    igmp_querier2    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan_2}
    
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=${mc_ip_1}  
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp2    ${mc_ip_2}
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp3    ${mc_ip_3}
    
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=${mc_ip_1}  
    add_one_multicast_group_to_igmp_host    tg1    igmp_host2    mc_grp2    ${mc_ip_2}
    add_one_multicast_group_to_igmp_host    tg1    igmp_host2    mc_grp3    ${mc_ip_3}

    log    STEP:6 Show mrouter in e7 Should contain sever-ip
    tg control igmp querier by name    tg1    igmp_querier1    start
    tg control igmp querier by name    tg1    igmp_querier2    start
    log    check igmp router
    service_point_check_igmp_routers    service_point1    ${mvr_vlan_1}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    service_point_check_igmp_routers    service_point1    ${mvr_vlan_2}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    STEP:7 Show mcast in e7 Should contain group 1 & 2 in server-ip 1, group 2 & 3 in server-ip 2
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_ip_1}    ${mvr_vlan_1}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_ip_2}    ${mvr_vlan_1}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_ip_3}    ${mvr_vlan_1}   contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_data_vlan}    ${mc_ip_1}    ${mvr_vlan_2}   contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_data_vlan}    ${mc_ip_2}    ${mvr_vlan_2}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_data_vlan}    ${mc_ip_3}    ${mvr_vlan_2}

    log    STEP:8 Create 6 bound traffics in IXIA, group11, 12, 13, 21, 22, 23 start traffic group 11, 12, 22, 23 traffics fully passed, group 13, 21 traffics fully lost
    create_bound_traffic_udp    tg1    ds_mc_traffic_11    service_p1    mc_grp1    igmp_querier1    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_12    service_p1    mc_grp2    igmp_querier1    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_13    service_p1    mc_grp3    igmp_querier1    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_21    service_p1    mc_grp1    igmp_querier2    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_22    service_p1    mc_grp2    igmp_querier2    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_23    service_p1    mc_grp3    igmp_querier2    ${p_mc_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep ${p_traffic_run_time} for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep ${p_traffic_stop_time} for traffic stop
    sleep    ${p_traffic_stop_time}
    
    log    verify traffic group 11, 12, 22, 23 traffics fully passed
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_11    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_12    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_22    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_23    ${p_traffic_loss_rate} 
    log    verify traffic group 13, 21 traffics fully lost
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_13
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_21

    log    STEP:9 Delete your configurations Success (see case teardown part)

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=mcast_prf2   cfg_prefix=sub2

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    delete_config_object    eutA    multicast-profile    mcast_prf2
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    delete_config_object    eutA    mvr-profile    mvr_prf2
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg control igmp querier by name    tg1    igmp_querier2    stop
    tg delete igmp querier    tg1    igmp_querier2
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    