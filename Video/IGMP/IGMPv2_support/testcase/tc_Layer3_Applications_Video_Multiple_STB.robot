*** Settings ***
Documentation     1 Configure a video subscriber to receive multicast. Attach 2 STBs to the port Both subscribers can watch video streams
...               2 Have the STBs watch the same channel. Change channel on one of them The second STB continues to receive video. The leave is not forwarded to the upstream router
Resource          ./base.robot

*** Variables ***
&{dict_igmp_host}    mc_grp=mcast_group

*** Test Cases ***
tc_Layer3_Applications_Video_Multiple_STB
    [Documentation]    1 Configure a video subscriber to receive multicast. Attach 2 STBs to the por Both subscribers can watch video streams
    ...    2 Have the STBs watch the same channel. Change channel on one of them The second STB continues to receive video. The leave is not forwarded to the upstream router
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1557    @globalid=2321631    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 Configure a video subscriber to receive multicast. Attach 2 STBs to the port Both subscribers can watch video streams
    log    STEP:2 Have the STBs watch the same channel. Change channel on one of them The second STB continues to receive video. The leave is not forwarded to the upstream router
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:Verify video is working and channel changes working.
    tg control igmp    tg1    igmp_host    join
    tg control igmp    tg1    igmp_host1    join
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
    tg control igmp    tg1    igmp_host1    leave
    ${res}    Run Keyword And Return Status    Wait Until Keyword Succeeds    30sec    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1
    ...    ${p_data_vlan}    @{p_groups_list}[0]    no
    Should Be True    ${FALSE}==${res}
    log    modify the group for the second STB
    Tg Modify Multicast Group    tg1    &{dict_igmp_host}[mc_grp]    ip_addr_start=@{p_groups_list}[1]
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[1]
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
    &{dict_igmp_host}    create_igmp_host    tg1    igmp_host1    subscriber_p1    v2    ${p_igmp_host1.mac}
    ...    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
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
