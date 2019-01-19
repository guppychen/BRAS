*** Settings ***
Documentation     Disable and then enable pon port and verify all of the ONTs on that PON port restore service successfully.
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Disable_enable_PON_port
    [Documentation]    Disable and then enable pon port and verify all of the ONTs on that PON port restore service successfully.
    [Tags]    @author=AnsonZhang    @TCID=AXOS_E72_PARENT-TC-1610    @globalid=2321685    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:Disable and then enable pon port and verify all of the ONTs on that PON port restore service successfully.
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:Join channels, either real, or simulated with STC Keep track of joins
    tg control igmp    tg1    igmp_host    join
    log    Show the snooping table. This would be a list of all the channels currently joined on the EUT
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    Using a traffic generator, send an IGMP leave to a host port.The snooping table should be updated correctly
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    5
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    log    disable the uplink interface and enable again
    shutdown_port    eutA    pon    @{service_model.subscriber_point1.attribute.pon_port}[0]
    no_shutdown_port    eutA    pon    @{service_model.subscriber_point1.attribute.pon_port}[0]
    Wait Until Keyword Succeeds    20sec    10sec    check_interface_up    eutA    pon    @{service_model.subscriber_point1.attribute.pon_port}[0]
    subscriber_point_ont_port_check_status    eutA    subscriber_point1    up
    log    check the groups joined
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    start the traffic again
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    5
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
