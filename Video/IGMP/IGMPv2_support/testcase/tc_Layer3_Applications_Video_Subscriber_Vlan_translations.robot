*** Settings ***
Documentation     1	Configure STC with a IGMP querier with vlan 300	IGMP querier succefully created
...    2	Configure Trunk port on the DUT with vlan 300	Trunk port created succefully
...    3	Configure a MVR profile with a multicast range and vlan 300	MVR profile created
...    4	Configure two subscribers on two uni port with cvid 10 and 20 respectively with service vlan 900	Video service for both port created successfully
...    5	Join same channel on both ports and verify subscribers are able to join muticast group with the correct vlans (10 and 20)		Use wireshark to capture packets on the subscriber
...    6	Join a different channel on the second subscriber and verify subscriber able to join and multicast streams are coming with cvid 20		Use wireshark to capture packets on the subscribe
Resource          ./base.robot


*** Variables ***
&{dict_igmp_host}    mc_grp=mcast_group
${sub_class_map}    sub_cmap
${sub_policy_map}    sub_pmap
${sub1_class_map}    sub1_cmap
${sub1_policy_map}    sub1_pmap

*** Test Cases ***
tc_Layer3_Applications_Video_Subscriber_Vlan_translations
    [Documentation]    1	Configure STC with a IGMP querier with vlan 300	IGMP querier succefully created
    ...    2	Configure Trunk port on the DUT with vlan 300	Trunk port created succefully
    ...    3	Configure a MVR profile with a multicast range and vlan 300	MVR profile created
    ...    4	Configure two subscribers on two uni port with cvid 10 and 20 respectively with service vlan 900	Video service for both port created successfully
    ...    5	Join same channel on both ports and verify subscribers are able to join muticast group with the correct vlans (10 and 20)		Use wireshark to capture packets on the subscriber
    ...    6	Join a different channel on the second subscriber and verify subscriber able to join and multicast streams are coming with cvid 20		Use wireshark to capture packets on the subscribe
    [Tags]       @author=AnsonZhang     @tcid=AXOS_E72_PARENT-TC-1550    @globalid=2321624    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure STC with a IGMP querier with vlan 300 IGMP querier succefully created

    log    STEP:2 Configure Trunk port on the DUT with vlan 300 Trunk port created succefully

    log    STEP:3 Configure a MVR profile with a multicast range and vlan 300 MVR profile created

    log    STEP:4 Configure two subscribers on two uni port with cvid 10 and 20 respectively with service vlan 900 Video service for both port created successfully

    log    STEP:5 Join same channel on both ports and verify subscribers are able to join muticast group with the correct vlans (10 and 20) Use wireshark to capture packets on the subscriber
    log    start the igmp querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_mvr_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}

    log    hosts join the groups
    tg control igmp    tg1    igmp_host    join
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_mvr_vlan}    @{p_mvr_start_ip_list}[0]

    tg control igmp    tg1    igmp_host1    leave
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_mvr_vlan}    @{p_mvr_start_ip_list}[0]
    log    STEP:6 Join a different channel on the second subscriber and verify subscriber able to join and multicast streams are coming with cvid 20 Use wireshark to capture packets on the subscribe
    log    change channel
    Tg Modify Multicast Group    tg1    &{dict_igmp_host}[mc_grp]    ip_addr_start=@{p_mvr_start_ip_list}[1]
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_mvr_vlan}    @{p_mvr_start_ip_list}[1]
    log    check the first group still there
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_mvr_vlan}    @{p_mvr_start_ip_list}[0]


*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300    pbit-priority=4    last-member-query-count=2    last-member-query-interval=50
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_mvr_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_mvr_vlan}
    log    prov video service
    log    configure class-map match vlan
    prov_class_map    eutA    ${sub_class_map}    ethernet    flow    1    1
    ...    vlan=${p_match_vlan}
    prov_class_map    eutA    ${sub1_class_map}    ethernet    flow    1    1
    ...    vlan=${p_match_vlan1}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${sub_policy_map}    class-map-ethernet    ${sub_class_map}    flow    1    remove-cevlan=${EMPTY}
    prov_policy_map    eutA    ${sub1_policy_map}    class-map-ethernet    ${sub1_class_map}    flow    1    remove-cevlan=${EMPTY}

    log    create the mvr profile and multicast profile for mvr
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_start_ip_list}[1]    ${p_mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf_mvr}    ${p_mvr_prf}

    log    subscribers use the same data vlan
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf_mvr}
    subscriber_point_add_svc_user_defined    subscriber_point2    ${p_data_vlan}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf_mvr}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    &{dict_igmp_host}    create_igmp_host    tg1    igmp_host1    subscriber_p2    v2    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}
    ...    ${p_igmp_host2.gateway}    ${p_match_vlan1}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_mvr_vlan}    query_interval=30

case teardown
    log    remove the service
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${sub_policy_map}    mcast_profile=${p_mcast_prf_mvr}
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${p_data_vlan}    ${sub1_policy_map}    mcast_profile=${p_mcast_prf_mvr}
    delete_config_object    eutA    policy-map    ${sub_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub_class_map}
    delete_config_object    eutA    policy-map    ${sub1_policy_map}
    delete_config_object    eutA    class-map    ethernet ${sub1_class_map}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    dprov_vlan    eutA    ${p_mvr_vlan}    igmp-profile
    delete_config_object    eutA    igmp-profile    ${p_igmp_prf}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf_mvr}
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
