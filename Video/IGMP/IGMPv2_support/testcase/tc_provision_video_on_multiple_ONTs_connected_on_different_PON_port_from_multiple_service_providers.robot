*** Settings ***
Documentation     1 create 2 non-mvr service with mcast-map & mcast-white-list. Success. And 2 white-list should be overlap.
...               2 create 2 igmp hosts,Success
...               3 create 3 multicast group,group1,group2,group3,Success
...               4 host1 with group1 and group2.Success
...               5 host2 with group2 and group3.Success
...               6 create 2 igmp queries,Success
...               7 start igmp query, show mrouter check server vlan and server ip
...               8 start to join igmp host. show mcast check server vlan and multicast addr
...               9 create 4 igmp traffic. query1 to host1-group1, query1 to host1-group2, query2 to host2-group2,query2 to host2-group3 each traffic passed with no loss
Resource          ./base.robot

*** Variables ***
${sub_class_map}    sub_cmap
${sub_policy_map}    sub_pmap
${sub1_class_map}    sub1_cmap
${sub1_policy_map}    sub1_pmap
${igmp_group_session_num}    2

*** Test Cases ***
tc_provision_video_on_multiple_ONTs_connected_on_different_PON_port_from_multiple_service_providers
    [Documentation]    1 create 2 non-mvr service with mcast-map & mcast-white-list. Success. And 2 white-list should be overlap.
    ...    2 create 2 igmp hosts,Success
    ...    3 create 3 multicast group,group1,group2,group3 Success
    ...    4 host1 with group1 and group2. Success
    ...    5 host2 with group2 and group3. Success
    ...    6 create 2 igmp queries Success
    ...    7 start igmp query, show mrouter check server vlan and server ip
    ...    8 start to join igmp host. show mcast check server vlan and multicast addr
    ...    9 create 4 igmp traffic. query1 to host1-group1, query1 to host1-group2, query2 to host2-group2,query2 to host2-group3 each traffic passed with no loss
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1602    @globalid=2321677    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 create 2 non-mvr service with mcast-map & mcast-white-list. Success. And 2 white-list should be overlap.
    log    STEP:2 create 2 igmp hosts Success
    log    STEP:3 create 3 multicast group,group1,group2,group3 Success
    log    STEP:4 host1 with group1 and group2. Success
    log    STEP:5 host2 with group2 and group3. Success
    log    STEP:6 create 2 igmp queries Success
    log    STEP:7 start igmp query, show mrouter check server vlan and server ip
    log    start the igmp querier
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp querier by name    tg1    igmp_querier1    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan1}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier1.ip}
    log    STEP:8 start to join igmp host. show mcast check server vlan and multicast addr
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[1]
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point3    ${p_data_vlan1}    @{p_groups_list}[2]
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point3    ${p_data_vlan1}    @{p_groups_list}[3]
    log    STEP:9 create 4 igmp traffic. query1 to host1-group1, query1 to host1-group2, query2 to host2-group2,query2 to host2-group3 each traffic passed with no loss
    log    create traffic
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    mcast_stream1    subscriber_p2    service_p1    ovlan=${p_data_vlan1}    mac_dst=@{p_groups_mac_list}[2]
    ...    mac_src=${p_igmp_querier1.mac}    ip_dst=@{p_groups_list}[2]    ip_src=${p_igmp_querier1.ip}    rate_mbps=${rate_mbps1}
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
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[1]
    ...    no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point3    ${p_data_vlan1}    @{p_groups_list}[2]
    ...    no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point3    ${p_data_vlan1}    @{p_groups_list}[3]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300    pbit-priority=4    last-member-query-count=2    last-member-query-interval=50
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
    subscriber_point_add_svc_user_defined    subscriber_point3    ${p_data_vlan1}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    create_igmp_host    tg1    igmp_host1    subscriber_p2    v2    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}
    ...    ${p_igmp_host2.gateway}    ${p_match_vlan1}    session=${igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[2]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}    query_interval=60
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}
    ...    ${p_igmp_querier1.gateway}    ${p_data_vlan1}    query_interval=60

case teardown
    log    remove the service
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc_user_defined    subscriber_point3    ${p_data_vlan1}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf}
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
