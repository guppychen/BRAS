*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***


*** Keywords ***
template_ring_switch_mvr_video
    [Arguments]    ${version}    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_type}    ${ring_service_point_list}    ${switch_port}
    [Documentation]    1	Configure a trunk port with all the MVR vlans	Trunk port with all vlans should be created	Use the command "show bridge table" to verify
    ...    2	Configure STC port with 4 IGMP quirier with the corresponding MVR vlans	Trunk port should become router port and in HAPPY state	Use the command "show igmp ports" and "show igmp domains"to verify
    ...    3	Send multicast streams with the MVR muticast address range and associated vlan from the same STC port		
    ...    4	Configure an MVR profile that uses 4 vlans with different multicast address range	The profile is accepted	
    ...    5	Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile	UNI service should be created	
    ...    6	Join the muticast group of all 4 vlans	Able to join the multicast group	Use wireshark and cature ithe IGMP joins make sure it has the correct vlan
    ...    7	Configure a trunk port with the service vlan		
    ...    8	Send Bidirectional unicast traffic on the UNI port		
    ...    9	Using wireshark capture the packets on the trunk port with service vlan	Unicast traffic should be received with the service vlan	
    ...    10	Using wireshark capture the packets on the uni port	Unicast traffic should be received untagged	
    ...    11	Remove service from the uni port	Remove operation should be successful	
    [Tags]       @author=CindyGao
    [Teardown]   mvr_template_teardown    ${subscriber_point}
    log    case setup: subscriber side provision
    set test variable    ${subscriber_eut}    ${service_model.${subscriber_point}.device}
    set test variable    ${uplink_eth_point}    @{service_model.${uplink_eth_service_point_list}}[0]    
    
    log    STEP:1 create mvr profile, multicast profile and add to subscriber_point
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    ${subscriber_eut}    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    ${subscriber_eut}    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}    
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    ${subscriber_point}    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}  

    log    check node status
    subscriber_point_check_status_up    ${subscriber_point}
    service_point_list_check_status_up    ${uplink_eth_service_point_list}
    service_point_list_check_status_up    ${ring_service_point_list}
    
    log    STEP:2 Configure STC port with 4 IGMP quirier with the corresponding MVR vlans Trunk port should become router port and in HAPPY state Use the command "show igmp ports" and "show igmp domains"to verify
    log    create igmp querier and check
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    ${version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start

    Run Keyword If    '${EMPTY}'!='${ring_type}'    check_igmp_querier_mvr    ${ring_service_point_list}    ${version}
    ...    ELSE    check_igmp_querier_mvr    ${uplink_eth_service_point_list}    ${version}

    log    STEP:3 Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    ${list_mc_grp_name}    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}

    log    STEP:4 Join the muticast group of all 4 vlans Able to join the multicast group Use wireshark and cature ithe IGMP joins make sure it has the correct vlan
    tg control igmp    tg1    igmp_host    join
    log    sleep for igmp join
    sleep    5s
    log    check igmp multicast group on subscriber connected device
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    ${subscriber_point}    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]
    check_igmp_multicast_group_on_ring_node    ${ring_type}    ${ring_service_point_list}

    log    STEP:5 Send DHCP traffic on the UNI port
    create_dhcp_server    tg1    dhcps    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.pool_start}    ${p_data_vlan}
    create_dhcp_client    tg1    dhcpc    subscriber_p1    dhcpc_group    ${p_dhcp_client.mac}    ${p_match_vlan}
    Tg Control Dhcp Server    tg1    dhcps    start
    Tg Control Dhcp Client    tg1    dhcpc_group    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${p_lease_negotiated_time}

    log    STEP:6 generate bi-directional unicast traffic for the client
    create_bound_traffic_udp    tg1    us_data_traffic    subscriber_p1    dhcps    dhcpc_group    ${p_us_data_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_data_traffic    service_p1    dhcpc_group    dhcps    ${p_ds_data_traffic_rate_mbps}
    
    log    STEP:7 generate multicast downstream traffic
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_bound_traffic_udp    tg1    ds_mc_traffic${index}    service_p1    @{list_mc_grp_name}[${index}]    igmp_querier${index}    ${p_mc_traffic_rate_mbps}
    
    log    STEP:8 send all traffic and verify no drop packet
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}
    
    log    STEP:9 switch ring by shutdown forwarding port
    shutdown_port    ${subscriber_eut}    ethernet    ${switch_port}
    log    sleep for ring switch after port shutdown
    sleep    10s
    log    show ring status
    : FOR    ${service_point}    IN    @{service_model.${ring_service_point_list}}
    \    ${device}    set variable    ${service_model.${service_point}.device}
    \    log    ****** service provision check for ${device} ${service_point} ******
    \    cli    ${device}    show ${ring_type} ${service_model.${service_point}.name} status   
        
    log    STEP:10 check igmp multicast group and verify no drop packet
    check_igmp_group_mvr    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}
    
    log    STEP:11 revert switch ring by no shutdown port
    no_shutdown_port    ${subscriber_eut}    ethernet    ${switch_port}
    Wait Until Keyword Succeeds    ${p_ring_switch_time}    10sec    service_point_list_check_status_up    ${ring_service_point_list}
    
    log    STEP:12 check igmp multicast group and verify no drop packet
    check_igmp_group_mvr    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    send_traffic_and_check_loss    tg1    ${subscriber_point}    ${uplink_eth_service_point_list}    ${ring_service_point_list}

check_igmp_group_mvr
    [Arguments]    ${subscriber_point}    ${ring_type}    ${ring_service_point_list}
    [Documentation]    Description: mvr video check igmp multicast group on ring node with subscriber_point
    ...
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | subscriber_point | subscriber_point name in service_model.yaml |
    ...    | ring_type | ring_type, {erps|g.8032} |
    ...    | ring_service_point_list | ring service_point_list name in service_model.yaml |
    [Tags]       @author=CindyGao
    log    check igmp multicast group on subscriber connected device and uplink device
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    Wait Until Keyword Succeeds    5min    10sec    subscriber_point_check_igmp_multicast_group    ${subscriber_point}    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]
    check_igmp_multicast_group_on_ring_node    ${ring_type}    ${ring_service_point_list}