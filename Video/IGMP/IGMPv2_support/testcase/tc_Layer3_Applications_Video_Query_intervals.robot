*** Settings ***
Documentation     1 Configure the EUT to receive multicast information A STB can join and leave channels
...               2 Verify the default query interval is 125 seconds in the default IGMP profile SYSTEM and this timer is accurate. General queries are sent every 125 seconds
...               3 Set the general query interval to 30s General queries are sent every 10 seconds
...               4 Verify the query interval cant be set to a value less than the query response interval
Resource          ./base.robot

*** Variables ***
${wait_for_default_query_interval}    260sec
${wait_for_30s_query_interval}    80sec
${olt_mac_address}

*** Test Cases ***
tc_Layer3_Applications_Video_Query_intervals
    [Documentation]    1 Configure the EUT to receive multicast information A STB can join and leave channels
    ...    2 Verify the default query interval is 125 seconds in the default IGMP profile SYSTEM and this timer is accurate. General queries are sent every 125 seconds
    ...    3 Set the general query interval to 30s General queries are sent every 10 seconds
    ...    4 Verify the query interval cant be set to a value less than the query response interval
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1562    @globalid=2321636    @eut=GPON-8r2    @eut=NGPON2-4
    [Setup]    case setup
    log    get mac address
    ${olt_mac_address}    get_chassis_mac    eutA
    log    ${olt_mac_address}
    log    STEP:1 Configure the EUT to receive multicast information A STB can join and leave channels
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:2 Verify the default query interval is 125 seconds in the default IGMP profile SYSTEM and this timer is accurate. General queries are sent every 125 seconds
    log    start capture the query
    start_capture    tg1    subscriber_p1
    sleep    ${wait_for_default_query_interval}
    stop_capture    tg1    subscriber_p1
    ${tg_query}    save_and_analyze_packet_on_port    tg1    subscriber_p1    (igmp.type == 0x11 && eth.src==${olt_mac_address})
    Should Be true    3>=${tg_query}
    Should Be true    ${tg_query}>=2
    log    STEP:3 Set the general query interval to 30s General queries are sent every 10 seconds
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300
    log    wait for the previous timer time out
    sleep    125s
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]    no
    log    join again with the new query interval
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    start_capture    tg1    subscriber_p1
    sleep    ${wait_for_30s_query_interval}
    stop_capture    tg1    subscriber_p1
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ${tg_query1}    save_and_analyze_packet_on_port    tg1    subscriber_p1    (igmp.type == 0x11 && eth.src==${olt_mac_address})
    should be true    abs(3-${tg_query1})<=1
    Should Be true    ${tg_query1}>=2
    log    STEP:4 Verify the query interval cant be set to a value less than the query response interval
    ${res}    Run Keyword And Return Status    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-response-interval=310
    Should Be Equal    ${res}    ${FALSE}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}
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
