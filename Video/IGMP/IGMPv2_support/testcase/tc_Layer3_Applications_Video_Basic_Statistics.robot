*** Settings ***
Documentation     1 Configure a card for receiving and responding to IGMP traffic. This will include interface (router and host ports), vlan Configuration takes
...               2 Join channels, either real, or simulated with STC Keep track of joins
...               3 Issue the command "show igmp statistics" based on interface (router and host port) and vlan Verify that the stats match the STC stats
...               4 Clear the stats and repeat steps 3 and 4
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Layer3_Applications_Video_Basic_Statistics
    [Documentation]    1 Configure a card for receiving and responding to IGMP traffic. This will include interface (router and host ports), vlan Configuration takes
    ...    2 Join channels, either real, or simulated with STC Keep track of joins
    ...    3 Issue the command "show igmp statistics" based on interface (router and host port) and vlan Verify that the stats match the STC stats
    ...    4 Clear the stats and repeat steps 3 and 4
    [Tags]    @subfeature=IGMPv2 support    @TCID=AXOS_E72_PARENT-TC-1583    @globalid=2321657    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 Configure a card for receiving and responding to IGMP traffic. This will include interface (router and host ports), vlan Configuration takes
    log    clear the igmp statistic
    clear_igmp_statistics    eutA    all
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:2 Join channels, either real, or simulated with STC Keep track of joins
    log    start to capture the igmp at client
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    Leave channels
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    log    shutdown ont-port and get stats
    subscriber_point_shutdown    subscriber_point1
    log    get the statistic
    ${num_leave}    get_igmp_statistics    eutA    option=rx-leaves
    ${num_report}    get_igmp_statistics    eutA    option=rx-reports
    ${num_query}    get_igmp_statistics    eutA    option=tx-general-queries
    ${num_special_query}    get_igmp_statistics    eutA    option=tx-group-queries
    log    STEP:3 Issue the command "show igmp statistics" based on interface (router and host port) and vlan Verify that the stats match the STC stats
    log    stop the capture
    stop_capture    tg1    subscriber_p1
    log    check the igmp report packet
    ${tg_report}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type == 0x16
    Should Be Equal    ${num_report}    ${tg_report}
    log    check the igmp query from proxy
    ${tg_query}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type == 0x11
    ${sum_query}    Evaluate    ${num_query}+${num_special_query}
    Should Be true    ${sum_query}>=${tg_query}
    log    check the leave
    ${tg_leave}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type == 0x17&&ip.src==${p_igmp_host.ip}
    Should Be Equal    ${num_leave}    ${tg_leave}
    subscriber_point_no_shutdown    subscriber_point1
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}    general-query-interval=300    last-member-query-count=2
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
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    subscriber_point_no_shutdown    subscriber_point1
