*** Settings ***
Documentation     Test suite verify multicast L3 switch
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2

*** Test Cases ***
tc_multicast_L3_switch
    [Documentation]       Test suite verify multicast L3 switch
    ...    1	host 1 join group 225.0.0.1 and host 2 join group 226.0.0.1 from same pon port on different ont 	successful		
    ...    2	send multicast data to above group simultaneously from uplink	
    ...    host 1 can only receive dest ip 225.0.0.1 packets and host 2 can only receive dest ip 226.0.0.1 packets
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276069    @tcid=AXOS_E72_PARENT-TC-553
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Setup]   case setup
    [Teardown]   case teardown
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    subscriber_point_check_status_up    subscriber_point2
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    log    verify igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    log    STEP:1 host 1 join group 225.0.0.1 and host 2 join group 226.0.0.1 from same pon port on different ont successful
    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_group1    mc_group_start_ip=${p_mcast_start_ip}
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_name=mc_group2    mc_group_start_ip=${p_mcast_start_ip2}   
    
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2   join
    
    log    check igmp multicast group
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip2}
    log    check igmp multicast summary
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip2}

    log    STEP:2 send multicast data to above group simultaneously from uplink
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mc_group1    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic2    service_p1    mc_group2    igmp_querier    ${p_mc_traffic_rate_mbps}
    start_capture    tg1    subscriber_p1
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1
    stop_capture    tg1    subscriber_p1
    
    log    STEP:3 verify host 1 can only receive dest ip 225.0.0.1 packets and host 2 can only receive dest ip 226.0.0.1 packets
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_subscriber_p1}
    sleep    10s
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${p_mcast_start_ip})
    Wsk Load File    ${save_file_subscriber_p1}    (vlan.id == ${p_match_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${p_mcast_start_ip2})
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==0

    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (vlan.id == ${p_match_vlan_sub2}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${p_mcast_start_ip2})
    Wsk Load File    ${save_file_subscriber_p1}    (vlan.id == ${p_match_vlan_sub2}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${p_mcast_start_ip})
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==0

*** Keywords ***
case setup
    [Documentation]    case setup: subscriber side provision for sub2
    # subscriber_point_prov    subscriber_point2
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

case teardown
    [Documentation]    case teardown
    log    subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_video_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    