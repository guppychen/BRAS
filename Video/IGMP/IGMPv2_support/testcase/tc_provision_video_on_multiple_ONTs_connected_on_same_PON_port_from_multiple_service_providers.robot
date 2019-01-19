*** Settings ***
Documentation     Non MVR: provision video on multiple ONTs connected on same PON port from multiple service providers
...
...               Verify they all can view same channels and different channels at the same time.
Resource          ./base.robot

*** Variables ***
${sub_class_map}    sub_cmap
${sub_policy_map}    sub_pmap
${sub1_class_map}    sub1_cmap
${sub1_policy_map}    sub1_pmap

*** Test Cases ***
tc_provision_video_on_multiple_ONTs_connected_on_same_PON_port_from_multiple_service_providers
    [Documentation]    Non MVR: provision video on multiple ONTs connected on same PON port from multiple service providers
    ...
    ...    Verify they all can view same channels and different channels at the same time.
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1600    @globalid=2321675    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    start the igmp querier
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp querier by name    tg1    igmp_querier1    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan1}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier1.ip}
    log    STEP:Verify they all can view same channels and different channels at the same time.
    log    hosts join the groups
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    ${p_data_vlan1}    @{p_groups_list}[0]
    log    create traffic
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    mcast_stream1    subscriber_p2    service_p1    ovlan=${p_data_vlan1}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier1.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier1.ip}    rate_mbps=${rate_mbps1}
    log    verify the traffic
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream1    ${loss_rate}
    log    leave
    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host1    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point2    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    igmp-version=v2    general-query-interval=300    pbit-priority=4    last-member-query-count=2    last-member-query-interval=50
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan1}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan1}
    log    prov video service
    log    configure class-map match vlan
    prov_class_map    eutA    ${sub_class_map}    ethernet    flow    1    1
    ...    vlan=${p_match_vlan}
    prov_class_map    eutA    ${sub1_class_map}    ethernet    flow    1    1
    ...    vlan=${p_match_vlan1}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${sub_policy_map}    class-map-ethernet    ${sub_class_map}    flow    1    remove-cevlan=${EMPTY}
    prov_policy_map    eutA    ${sub1_policy_map}    class-map-ethernet    ${sub1_class_map}    flow    1    remove-cevlan=${EMPTY}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc_user_defined    subscriber_point2    ${p_data_vlan1}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    create_igmp_host    tg1    igmp_host1    subscriber_p2    v2    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}
    ...    ${p_igmp_host2.gateway}    ${p_match_vlan1}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}    query_interval=60
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}
    ...    ${p_igmp_querier1.gateway}    ${p_data_vlan1}    query_interval=60

case teardown
    log    remove the service
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${p_data_vlan1}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf}
    delete_config_object    eutA    policy-map    ${sub_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub_class_map}
    delete_config_object    eutA    policy-map    ${sub1_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub1_class_map}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    dprov_vlan    eutA    ${p_data_vlan}    igmp-profile
    dprov_vlan    eutA    ${p_data_vlan1}    igmp-profile
    delete_config_object    eutA    igmp-profile    ${p_igmp_prf}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
