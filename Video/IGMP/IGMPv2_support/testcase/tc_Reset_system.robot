*** Settings ***
Documentation     1 create service vlan,create igmp profile,set vlan igmp mode proxiy ,version v2 success
...               2 create multicast profile and provsion video service at access port success
...               3 strat the query and make the subscriber join one group success
...               4 show mrouter in e7 should contain server_ip
...               5 show mcast in e7 should contain group
...               6 create multicast traffic to the group traffic pass.
...               7 reboot the system succes
...               8 the group can be shown in the mcast table and traffic recover after the system ready success
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Reset_system
    [Documentation]    1 create service vlan,create igmp profile,set vlan igmp mode proxiy,version v2 success
    ...    2 create multicast profile and provsion video service at access port success
    ...    3 strat the query and make the subscriber join one group success
    ...    4 show mrouter in e7 should contain server_ip
    ...    5 show mcast in e7 should contain group
    ...    6 create multicast traffic to the group traffic pass.
    ...    7 reboot the system succes
    ...    8 the group can be shown in the mcast table and traffic recover after the system ready success
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-1692    @globalid=2321781    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 create service vlan,create igmp profile,set vlan igmp mode proxiy ,version v2 success
    log    STEP:2 create multicast profile and provsion video service at access port success
    log    STEP:3 strat the query and make the subscriber join one group success
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    log    STEP:4 show mrouter in e7 should contain server_ip
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:5 show mcast in e7 should contain group
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:6 create multicast traffic to the group traffic pass.
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    Tg Clear Traffic Stats    tg1
    log    STEP:7 reboot the system succes
    Reload System    eutA
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    # add this step as AT-4825
    sleep   60s
    stop_capture    tg1    service_p1
    stop_capture    tg1    service_p1
    log   analyze traffic result
    Tg Store Captured Packets    tg1    service_p1    /tmp/${TEST NAME}_service_p1.pcap
    Tg Store Captured Packets    tg1    subscriber_p1    /tmp/${TEST NAME}_subscriber_p1.pcap
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_status_up    subscriber_point1
    log    STEP:8 the group can be shown in the mcast table and traffic recover after the system ready success
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}    general-query-interval=300
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
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}    query_interval=30

case teardown
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
