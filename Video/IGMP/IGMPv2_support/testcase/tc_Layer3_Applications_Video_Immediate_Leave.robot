*** Settings ***
Documentation     1 Configure a subscriber for multicast. Ensure that immediate leave is enabled The subscriber can receive vider traffic, change channels Use the commend "show running-config profile igmp-profile | detail" to see the igmp-profile config
...               2 Send a leave for a particular channel The channel is removed from the snooping table for that subscriber, and group specific queries are not forwarded to the subscriber RLT-SR-4371
Resource          ./base.robot

*** Variables ***
${group_session_num}    1

*** Test Cases ***
tc_Layer3_Applications_Video_Immediate_Leave
    [Documentation]    1 Configure a subscriber for multicast. Ensure that immediate leave is enabled The subscriber can receive vider traffic, change channels Use the commend "show running-config profile igmp-profile | detail" to see the igmp-profile config
    ...    2 Send a leave for a particular channel The channel is removed from the snooping table for that subscriber, and group specific queries are not forwarded to the subscriber RLT-SR-4371
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1555    @globalid=2321629    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 Configure a subscriber for multicast. Ensure that immediate leave is enabled The subscriber can receive vider traffic, change channels Use the commend "show running-config profile igmp-profile | detail" to see the igmp-profile config
    log    STEP:2 Send a leave for a particular channel The channel is removed from the snooping table for that subscriber, and group specific queries are not forwarded to the subscriber RLT-SR-4371
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:Verify video is working and channel changes working.
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    Using a traffic generator
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    log    group leave
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    10sec    2sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}    general-query-interval=300    last-member-query-count=5    last-member-query-interval=50
    ...    immediate-leave=enable
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}
    log    prov video service
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}

case teardown
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
