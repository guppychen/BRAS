*** Settings ***
Documentation     Non-MVR Video with IGMP Proxy (Change Tag & p-bit 4 Match Priority Tag Subscriber Traffic): Add basic video service to two access interfaces. Perform the following tasks capturing traffic as the receive location for each task: Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber, generate requested multicast streams from querier, generate leave for each associated stream from each subscriber. -> The following  traffic is received at the subscriber with the subscriber tag value: general IGMP queries, requested multicast streams, two last member group specific IGMP queries after the leave. Downstream IGMP traffic p-bit = 4 (matched p-bit). Downstream multicast stream traffic p-bit = matched p-bit. The following single tagged with the changed-to-tag with p-bit = 4 traffic is received at the querier: joins/reports and leaves. No traffic is forwarded between the two lines.
Resource          ./base.robot


*** Variables ***
${sub_class_map}    sub_cmap_oui
${sub_policy_map}    sub_pmap_oui
${igmp_querier_name}    igmp_querier
${igmp_host_name}    igmp_host
${igmp_pbit_priority}    4
${group_session_num}    1

*** Test Cases ***
tc_Non_MVR_Video_with_IGMP_Proxy_Change_Tag_p_bit_4_Match_Priority_Tag_Subscriber_Traffic
    [Documentation]    Non-MVR Video with IGMP Proxy (Change Tag & p-bit 4 Match Priority Tag Subscriber Traffic): Add basic video service to two access interfaces. Perform the following tasks capturing traffic as the receive location for each task: Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber, generate requested multicast streams from querier, generate leave for each associated stream from each subscriber. -> The following  traffic is received at the subscriber with the subscriber tag value: general IGMP queries, requested multicast streams, two last member group specific IGMP queries after the leave. Downstream IGMP traffic p-bit = 4 (matched p-bit). Downstream multicast stream traffic p-bit = matched p-bit. The following single tagged with the changed-to-tag with p-bit = 4 traffic is received at the querier: joins/reports and leaves. No traffic is forwarded between the two lines.
    [Tags]       @author=AnsonZhang     @tcid=AXOS_E72_PARENT-TC-1668    @globalid=2321757    @priority=P2    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Non-MVR Video with IGMP Proxy (Change Tag & p-bit 4 Match Priority Tag Subscriber Traffic): Add basic video service to two access interfaces. Perform the following tasks capturing traffic as the receive location for each task: Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber, generate requested multicast streams from querier, generate leave for each associated stream from each subscriber. -> The following traffic is received at the subscriber with the subscriber tag value: general IGMP queries, requested multicast streams, two last member group specific IGMP queries after the leave. Downstream IGMP traffic p-bit = 4 (matched p-bit). Downstream multicast stream traffic p-bit = matched p-bit. The following single tagged with the changed-to-tag with p-bit = 4 traffic is received at the querier: joins/reports and leaves. No traffic is forwarded between the two lines.
    log    start the querier
    tg control igmp querier by name    tg1    ${igmp_querier_name}    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}

    log    STEP:Join channels, either real, or simulated with STC Keep track of joins
    tg control igmp    tg1    ${igmp_host_name}    join
    log    Show the snooping table. This would be a list of all the channels currently joined on the EUT
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    create and start the traffic
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}

    log    start the traffic
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}

    tg control igmp    tg1    ${igmp_host_name}    leave
    log    Show the snooping table.
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no

    log    start to capture the igmp packet
    start_capture    tg1    subscriber_p1
    start_capture    tg1    service_p1
    log    STEP:Join channels, either real, or simulated with STC Keep track of joins
    tg control igmp    tg1    ${igmp_host_name}    join
    log    Show the snooping table. This would be a list of all the channels currently joined on the EUT
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    leave group
    tg control igmp    tg1    ${igmp_host_name}    leave
    log    Show the snooping table.
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    log    sleep 10s to capture the gsq packet
    sleep    10s
    log    stop the capture
    stop_capture    tg1    subscriber_p1
    stop_capture    tg1    service_p1
    log    check the packets
    ${tg_gsq}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type==0x11&&igmp.maddr==@{p_groups_list}[0]
    Should Be true    ${tg_gsq}>=2
    ${query_num}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type == 0x11
    Should Be True    ${query_num}>=2
    log    check the report query received
    ${tg_rpt}    save_and_analyze_packet_on_port    tg1    service_p1    igmp.type==0x16&&vlan.priority==${igmp_pbit_priority}
    Should Be true    ${tg_rpt}>=1
    log    check the leave query received
    ${tg_leave}    save_and_analyze_packet_on_port    tg1    service_p1    igmp.type==0x17&&vlan.priority==${igmp_pbit_priority}
    Should Be true    ${tg_leave}>=1


*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300    pbit-priority=${igmp_pbit_priority}    last-member-query-count=2    last-member-query-interval=50
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}

    log    configure class-map match priority tagged
    prov_class_map    eutA    ${sub_class_map}    ethernet    flow    1    1    priority-tagged=${EMPTY}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${sub_policy_map}    class-map-ethernet    ${sub_class_map}    flow    1
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}

    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ovlan=0    ovlan_pbit=3    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}

case teardown
    log    remove the service
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    delete_config_object    eutA    policy-map    ${sub_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub_class_map}

    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
