*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***
${video_vlan}    @{p_video_vlan_list}[0]

*** Keywords ***
template_ring_switch_non_mvr_video
    [Arguments]    ${version}    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_type}    ${ring_service_point_list}    ${switch_port}
    [Tags]       @author=CindyGao
    [Teardown]   non_mvr_template_teardown    ${subscriber_point}
    log    case setup: subscriber side provision
    set test variable    ${subscriber_eut}    ${service_model.${subscriber_point}.device}
    set test variable    ${uplink_eth_point}    @{service_model.${uplink_eth_service_point_list}}[0]   
    
    log    STEP:1 create multicast profile and add to subscriber_point
    prov_multicast_profile    ${subscriber_eut}    ${p_mcast_prf}    max-streams=${p_mcast_max_stream}    
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    ${subscriber_point}    ${p_match_vlan}    ${video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}  
    
    log    check node status
    subscriber_point_check_status_up    ${subscriber_point}
    service_point_list_check_status_up    ${uplink_eth_service_point_list}
    service_point_list_check_status_up    ${ring_service_point_list}
    
    log    STEP:2 Configure STC port with IGMP quirier
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start

    log    check igmp querier
    check_igmp_querier_non_mvr    ${ring_service_point_list}    ${version}

    log    STEP:3 Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    &{dict_name}    create_igmp_host    tg1    igmp_host    subscriber_p1    ${version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host    join
    log    sleep for igmp join
    sleep    5s
    
    log    STEP:4 check igmp multicast group on subscriber connected device
    check_igmp_group_non_mvr    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    
    log    STEP:5 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic    service_p1    &{dict_name}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}
    
    log    STEP:6 switch ring by shutdown forwarding port
    shutdown_port    ${subscriber_eut}    ethernet    ${switch_port}
    log    sleep for ring switch after port shutdown
    sleep    10s
    log    show ring status
    : FOR    ${service_point}    IN    @{service_model.${ring_service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** service provision check for ${device} ${service_point} ******
    \    cli    ${device}    show ${service_model.${service_point}.type} ${service_model.${service_point}.name} status     

    log    STEP:7 check igmp multicast group and verify no drop packet
    check_igmp_group_non_mvr    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}
    
    log    STEP:8 revert switch ring by no shutdown port
    no_shutdown_port    ${subscriber_eut}    ethernet    ${switch_port}
    Wait Until Keyword Succeeds    ${p_ring_switch_time}    10sec    service_point_list_check_status_up    ${ring_service_point_list}

    log    STEP:9 check igmp multicast group and verify no drop packet
    check_igmp_group_non_mvr    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}

check_igmp_group_non_mvr
    [Arguments]    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    [Documentation]    Description: non-mvr video check igmp multicast group on ring node with subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | ring_type | ring_type, {erps|g.8032} |
    ...    | ring_service_point_list | ring service_point_list name in service_model.yaml |
    [Tags]       @author=CindyGao
    log    check igmp multicast group on subscriber connected device and uplink device
    Wait Until Keyword Succeeds    5min    10sec    subscriber_point_check_igmp_multicast_group    ${subscriber_point}    ${video_vlan}    @{p_mvr_start_ip_list}[0]
    check_non_mvr_igmp_multicast_group_on_ring_node    ${ring_type}    ${ring_service_point_list}
