*** Settings ***
Documentation     1	create video service with macst-white-list.	Success.
...    2	create 1 sever and 1 host with 1 group and group can't be watched Success.
...    3	start server and host, show mrouter and mcast. Should contain server ip,service vlan,and group
...    4	create multicast traffi roup passed with no loss
...    5	reset ONT Success.ONT arrival again
...    6	traffic resume.	As step4.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Reset_ONT
    [Documentation]   1 create video service with macst-white-list. Success.
    ...    2 create 1 sever and 1 host with 1 group and group can't be watched Success.
    ...    3 start server and host, show mrouter and mcast. Should contain server ip,service vlan,and group
    ...    4 create multicast traffic Group passed with no loss
    ...    5 reset ONT Success.ONT arrival again
    ...    6 traffic resume. As step4.
    [Tags]       @author=AnsonZhang     @tcid=AXOS_E72_PARENT-TC-1691    @globalid=2321780    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create video service with macst-white-list. Success.

    log    STEP:2 create 1 sever and 1 host with 1 group and group can't be watched Success.
    log    Using a traffic generator
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    verify traffic stream all pkt loss    tg1    mcast_stream

    log    STEP:3 start server and host, show mrouter and mcast. Should contain server ip,service vlan,and group
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}

    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:4 create multicast traffic Group passed with no loss
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    log    STEP:5 reset ONT Success.ONT arrival again
    perform_ont    eutA    ont_id=${service_model.subscriber_point1.attribute.ont_id}    action=reset
    log    check the ont status
    Wait Until Keyword Succeeds    1min    5sec    subscriber_point_check_status_up    subscriber_point1
    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:6 traffic resume. As step4.
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}

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
