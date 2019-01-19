*** Settings ***
Documentation     Multi-Interface Stream Limit Increase: Provisioned basic video service to multiple access interfaces using same mcast-profile. Proxy IGMP mode in use. Actively join a stream+1 greater than the provisioned max-streams on each line. Increase the max-streams to +1 greater value. -> Initially each line forwards only up the max-streams and not the +1 stream. After the max-streams is modified all streams are forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
Resource          ./base.robot

*** Variables ***
${sub_class_map}    sub_cmap
${sub_policy_map}    sub_pmap
${max_streams_min}    2
${max_streams_max}    3
${group_session}    4

*** Test Cases ***
tc_Multi_Interface_Stream_Limit_Increase
    [Documentation]    Multi-Interface Stream Limit Increase: Provisioned basic video service to multiple access interfaces using same mcast-profile. Proxy IGMP mode in use. Actively join a stream+1 greater than the provisioned max-streams on each line. Increase the max-streams to +1 greater value. -> Initially each line forwards only up the max-streams and not the +1 stream. After the max-streams is modified all streams are forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1647    @globalid=2321722    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:Multi-Interface Stream Limit Increase: Provisioned basic video service to multiple access interfaces using same mcast-profile. Proxy IGMP mode in use. Actively join a stream+1 greater than the provisioned max-streams on each line. Increase the max-streams to +1 greater value. -> Initially each line forwards only up the max-streams and not the +1 stream. After the max-streams is modified all streams are forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${max_streams_min}
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    start the igmp host to join
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_min}
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_min}*2
    log    leave the groups and modify the limit
    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host1    leave
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    0
    log    modify the limit
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${max_streams_max}
    log    start the igmp host to join
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_max}
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_max}*2
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile

    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300    pbit-priority=4    last-member-query-count=2    last-member-query-interval=50
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}
    log    prov video service
    log    configure class-map match vlan
    prov_class_map    eutA    ${sub_class_map}    ethernet    flow    1    1
    ...    vlan=${p_match_vlan}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${sub_policy_map}    class-map-ethernet    ${sub_class_map}    flow    1    remove-cevlan=${EMPTY}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc_user_defined    subscriber_point2    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${group_session}    mc_group_start_ip=@{p_groups_list}[0]
    create_igmp_host    tg1    igmp_host1    subscriber_p2    v2    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}
    ...    ${p_igmp_host1.gateway}    ${p_match_vlan}    session=${group_session}    mc_group_start_ip=@{p_groups_list1}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}    query_interval=60

case teardown
    log    remove the service
    tg save config into file    tg1   /tmp/igmp_v2_support.xml
    log    save done!!
    sleep   33
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf}
    delete_config_object    eutA    policy-map    ${sub_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub_class_map}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
