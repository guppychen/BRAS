*** Settings ***
Documentation     Non-MVR Multicast Video with Unicast Video simultaneously (Subscriber tagged): Add basic video service to ONT/xDSL line. Generate bidirectional unicast traffic at some rate lower than the bw-profile. Total DS bandwidth provisioned on a DSL interface includes both unicast and multicast video where as total DS bandwidth on GPON ONT includes only unicast video bandwidth. Join a multicast channel that makes total bw forwarded downstream slightly lower than the bw-profile. -> Both the bi-directional unicast traffic and the downstream multicast stream are forwarded with no losses.
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Non_MVR_Multicast_Video_with_Unicast_Video_simultaneously_Subscriber_tagged
    [Documentation]    Non-MVR Multicast Video with Unicast Video simultaneously (Subscriber tagged): Add basic video service to ONT/xDSL line. Generate bidirectional unicast traffic at some rate lower than the bw-profile. Total DS bandwidth provisioned on a DSL interface includes both unicast and multicast video where as total DS bandwidth on GPON ONT includes only unicast video bandwidth. Join a multicast channel that makes total bw forwarded downstream slightly lower than the bw-profile. -> Both the bi-directional unicast traffic and the downstream multicast stream are forwarded with no losses.
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-1654    @globalid=2321731    @priority=P2    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:Non-MVR Multicast Video with Unicast Video simultaneously (Subscriber tagged): Add basic video service to ONT/xDSL line. Generate bidirectional unicast traffic at some rate lower than the bw-profile. Total DS bandwidth provisioned on a DSL interface includes both unicast and multicast video where as total DS bandwidth on GPON ONT includes only unicast video bandwidth. Join a multicast channel that makes total bw forwarded downstream slightly lower than the bw-profile. -> Both the bi-directional unicast traffic and the downstream multicast stream are forwarded with no losses.
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
    log    create the unicast traffic
    create_raw_traffic_udp    tg1    ds    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=${p_igmp_host.mac}
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=${p_igmp_host.ip}    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    us    service_p1    subscriber_p1    ovlan=${p_match_vlan}    mac_dst=${p_igmp_querier.mac}
    ...    mac_src=${p_igmp_host.mac}    ip_dst=${p_igmp_querier.ip}    ip_src=${p_igmp_host.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    tg save config into file      tg1       /tmp/igmp_v2_2321731_two_reset_session.xml
    log   save done!!
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    ds    ${loss_rate}
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300
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
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}

case teardown
    log    delete the traffic
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
