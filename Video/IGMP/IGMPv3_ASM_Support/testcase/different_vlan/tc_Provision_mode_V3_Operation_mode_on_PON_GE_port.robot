*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Provision_mode_V3_Operation_mode_on_PON_GE_port
    [Documentation]    1	Connect V3 router and V2 STB	V2 join/leave will be successfu v2 join/leave would forward to uplink as V3 PON interface IGMP operation mode is V3.
    ...    2	Connect V2 router and V2 STB	V2 query RX on uplink port would be discard. Igmp v2 join and leave and subsciber will be discarded
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2261    @GlobalID=2346528
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Connect V3 router and V2 STB V2 join/leave will be successfu v2 join/leave would forward to uplink as V3 PON interface IGMP operation mode is V3.

    log    STEP:2 Connect V2 router and V2 STB V2 query RX on uplink port would be discard. Igmp v2 join and leave and subsciber will be discarded

    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    create_igmp_querier    tg1    igmp_querier2    service_p1    v3    ${p_igmp_querier2.mac}    ${p_igmp_querier2.ip}    ${p_igmp_querier2.gateway}    @{p_video_vlan_list}[1]
    tg control igmp querier by name    tg1    igmp_querier1    start
    tg control igmp querier by name    tg1    igmp_querier2    start
    log    check igmp querier on uplink eth device
    check_igmp_routers_sumarry_not_contain    eutA    @{p_video_vlan_list}[0]    ${service_model.service_point1.member.interface1}    V2    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[1]    @{p_proxy_2.ip}[0]    ${p_igmp_querier2.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[1]    subscriber_point2    V3    @{p_proxy_2.ip}[0]

    log    Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v2    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    create_igmp_host    tg1    igmp_host2    subscriber_p1    v3    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_host2.gateway}    ${p_match_vlan_switch2}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    sleep    ${wait_igmp_client_join_leave}

    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    @{service_model.subscriber_point1.attribute.pon_port}[0]
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[1]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary_not_contain    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point2.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[1]


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2261 setup
    log    set up all video vlan to V3 mode
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V3
    prov_igmp_profile    eutA    ${p_igmp_profile2}    V3

case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2261 teardown
    prov_igmp_profile    eutA    ${p_igmp_profile1}    auto
    prov_igmp_profile    eutA    ${p_igmp_profile2}    auto
    tg control igmp    tg1    igmp_host1    leave
    tg control igmp    tg1    igmp_host2    leave
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg control igmp querier by name    tg1    igmp_querier2    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg delete igmp querier    tg1    igmp_querier2
    tg delete igmp    tg1    igmp_host1
    tg delete igmp    tg1    igmp_host2
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}