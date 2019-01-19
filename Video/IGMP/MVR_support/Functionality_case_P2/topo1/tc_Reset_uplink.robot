*** Settings ***
Documentation     Pull the uplink and put it back and verify video services are restored
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${first_range}    @{p_mvr_network_list}[0].10
${last_range}    @{p_mvr_network_list}[0].20
${first_range_minus_1}    @{p_mvr_network_list}[0].9
${last_range_add_1}    @{p_mvr_network_list}[0].21

${uplink_port_type}    ${service_model.service_point1.attribute.interface_type}
${uplink_port_name}    ${service_model.service_point1.name}

*** Test Cases ***
tc_Reset_uplink
    [Documentation]    1	create mcast vlan, mvlan1, igmp mode proxy, version v2, create igmp profile, add range1	success		
    ...    2	create mcast profile, use mvr profile	success		
    ...    3	Create bw-profile, svc-match-list, svc-tag-action	success		
    ...    4	add eth-svc Video to subscriber port, with mcast profile	success		
    ...    5	create igmp server and client in IXIA, 4 groups, first range address -1， first range address, last range address, last range address +1, start protocol	show cast and mrouter, can see only 2 groups in range can be seen		
    ...    6	create 4 bounded traffics, start	only 2 groups in range can pass with loss, the other two fully lossed		
    ...    7	stop all traffic	stopped		
    ...    8	disable uplink eth-port and interface	success		
    ...    9	enable uplink eth-port and interface	success		
    ...    10	show mrouter and mcast	wait mrouter and mcast back		
    ...    11	start all traffic again	no traffic loss for in range's group		
    ...    12	delete all configuration	success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1463    @globalid=2321531    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create mcast vlan, mvlan1, igmp mode proxy, version v2, create igmp profile, add range1 success (Done in init file)

    log    STEP:2 create mcast profile, use mvr profile success
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${first_range}    ${last_range}    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:3 Create bw-profile, svc-match-list, svc-tag-action success
    log    STEP:4 add eth-svc Video to subscriber port, with mcast profile success
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:5 create igmp server and client in IXIA, 4 groups, first range address -1， first range address, last range address, last range address +1, start protocol show cast and mrouter, can see only 2 groups in range can be seen
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    
    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=${first_range} 
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp2    ${last_range}
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp3    ${first_range_minus_1}
    add_one_multicast_group_to_igmp_host    tg1    igmp_host1    mc_grp4    ${last_range_add_1}
    
    log    start igmp host and check only 2 groups in range can be seen
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${first_range}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${last_range}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${first_range_minus_1}    ${mvr_vlan}   contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${last_range_add_1}    ${mvr_vlan}   contain=no

    log    STEP:6 create 4 bounded traffics, start only 2 groups in range can pass with loss, the other two fully lossed
    create_bound_traffic_udp    tg1    ds_mc_traffic_1    service_p1    mc_grp1    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_2    service_p1    mc_grp2    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_3    service_p1    mc_grp3    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic_4    service_p1    mc_grp4    igmp_querier    ${p_mc_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep ${p_traffic_run_time} for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep ${p_traffic_stop_time} for traffic stop
    sleep    ${p_traffic_stop_time}
    
    log    verify traffic group in range can pass with loss
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_1    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_2    ${p_traffic_loss_rate} 
    log    verify traffic group out range traffics fully lost
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_3
    verify_traffic_stream_all_pkt_loss    tg1    ds_mc_traffic_4

    log    STEP:8 disable uplink eth-port and interface success
    shutdown_port    eutA    ${uplink_port_type}    ${uplink_port_name}

    log    STEP:9 enable uplink eth-port and interface success
    no_shutdown_port    eutA    ${uplink_port_type}    ${uplink_port_name}

    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    # add this step as AT-4825
    #tg control igmp querier by name    tg1    igmp_querier    start
    sleep   60s
    stop_capture    tg1    service_p1
    stop_capture    tg1    service_p1
    log   analyze traffic result
    Tg Store Captured Packets    tg1    service_p1    /tmp/${TEST NAME}_service_p1.pcap
    Tg Store Captured Packets    tg1    subscriber_p1    /tmp/${TEST NAME}_subscriber_p1.pcap

    log    STEP:10 show mrouter and mcast wait mrouter and mcast back
    Wait Until Keyword Succeeds    ${p_igmp_recover_time}    10sec    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    Wait Until Keyword Succeeds    ${p_igmp_recover_time}    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${first_range}    ${mvr_vlan}
    Wait Until Keyword Succeeds    ${p_igmp_recover_time}    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${last_range}    ${mvr_vlan}

    log    STEP:11 start all traffic again no traffic loss for in range's group
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep ${p_traffic_run_time} for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep ${p_traffic_stop_time} for traffic stop
    sleep    ${p_traffic_stop_time}
    
    log    verify traffic group in range can pass with loss
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_1    ${p_traffic_loss_rate} 
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic_2    ${p_traffic_loss_rate}

    log    STEP:12 delete all configuration success (See case teardown part)


*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1

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
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
