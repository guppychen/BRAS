*** Settings ***
Documentation     Stream Limit (w/ Dynamic MACFF): Add basic video service to an access interface using any max multicast stream value. Proxy IGMP mode in use. MACFF, IP Source Verify, and DHCP Snooping enabled on the VLAN. Force a client to obtain an IP address and join the limit + 1 stream. -> All streams but one stream is forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
Resource          ./base.robot

*** Variables ***
${max_streams_min}    1
${igmp_group_session_num}    2

*** Test Cases ***
tc_Stream_Limit_w_Dynamic_MACFF
    [Documentation]    Stream Limit (w/ Dynamic MACFF): Add basic video service to an access interface using any max multicast stream value. Proxy IGMP mode in use. MACFF, IP Source Verify, and DHCP Snooping enabled on the VLAN. Force a client to obtain an IP address and join the limit + 1 stream. -> All streams but one stream is forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    [Tags]    @subfeature=IGMPv2 support    @TCID=AXOS_E72_PARENT-TC-1644    @globalid=2321719    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:Stream Limit (w/ Dynamic MACFF): Add basic video service to an access interface using any max multicast stream value. Proxy IGMP mode in use. MACFF, IP Source Verify, and DHCP Snooping enabled on the VLAN. Force a client to obtain an IP address and join the limit + 1 stream. -> All streams but one stream is forwarded. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    log    start the dhcp server
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    Wait Until Keyword Succeeds    20sec    3sec    check_l3_hosts    eutA    num=1    vlan=${p_data_vlan}
    ...    host-type=mff-dynamic
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:Join channels, either real, or simulated with STC Keep track of joins
    tg control igmp    tg1    igmp_host    join
    log    Show the snooping table. This would be a list of all the channels currently joined on the EUT
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    Wait Until Keyword Succeeds    10sec    5sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[1]
    ...    no
    log    create traffic
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[0]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[0]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    TG Verify Traffic Loss For Stream Is Within    tg1    mcast_stream    ${loss_rate}
    log    delete the traffic
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    create traffic for the max+1 stream
    create_raw_traffic_udp    tg1    mcast_stream    subscriber_p1    service_p1    ovlan=${p_data_vlan}    mac_dst=@{p_groups_mac_list}[1]
    ...    mac_src=${p_igmp_querier.mac}    ip_dst=@{p_groups_list}[1]    ip_src=${p_igmp_querier.ip}    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Comment    sleep 5 seconds for stats stable
    sleep    ${time_before_verify_traffic}
    verify traffic stream all pkt loss    tg1    mcast_stream
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}
    log    create dhcp profile
    prov_dhcp_profile    eutA    dhcpp
    log    enable ipsv and mff
    prov_vlan    eutA    ${p_data_vlan}    dhcpp    mff=ENABLED    source-verify=ENABLED
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${max_streams_min}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}
    log    prov video service
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    log    create dhcp server and dhcp client
    Tg Create Dhcp Server On Port    tg1    dserver    service_p1    local_mac=${p_dhcp_server.mac}    ip_version=4    ip_address=${p_dhcp_server.ip}
    ...    ip_gateway=${p_dhcp_server.ip}    encapsulation=ETHERNET_II_VLAN    vlan_id=${p_data_vlan}    dhcp_ack_options=1    dhcp_ack_router_adddress=${p_dhcp_server.ip}    ipaddress_pool=${p_dhcp_server.pool_start}
    ...    ipaddress_count=2    lease_time=1000
    create_dhcp_client    tg1    dclient    subscriber_p1    dgroup    ${p_dhcp_client.mac}    ${p_match_vlan}
    log    create igmp host and querier
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
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
    dprov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile
    log    delete all traffic
    run keyword and ignore error    Tg Delete All Traffic    tg1
