*** Settings ***
Documentation     Non-MVR Video with IGMP Proxy Invalid IGMP Join/Report Mcast Address: Add basic video service to access interface. Perform the following tasks capturing traffic at the uplink for each task. At subscriber generate the following invalid IGMP joins/reports frames: group address is unicast ip address-> No group joined.
Resource          ./base.robot

*** Variables ***
${group_session_num}    1
${invlalid_address}    10.1.1.1

*** Test Cases ***
tc_Non_MVR_Video_with_IGMP_Proxy_Invalid_IGMP_Join_Report_Mcast_Address
    [Documentation]    Non-MVR Video with IGMP Proxy Invalid IGMP Join/Report Mcast Address: Add basic video service to access interface. Perform the following tasks capturing traffic at the uplink for each task. At subscriber generate the following invalid IGMP joins/reports frames: group address is unicast ip address-> No group joined.
    [Tags]    @author=AnsonZhang    @tcid=AXOS_E72_PARENT-TC-1670    @globalid=2321759    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2    ticket=EXA-19960    ticket=EXA-26410
    [Setup]    case setup
    log    STEP:Non-MVR Video with IGMP Proxy Invalid IGMP Join/Report Mcast Address: Add basic video service to access interface. Perform the following tasks capturing traffic at the uplink for each task. At subscriber generate the following invalid IGMP joins/reports frames: group address is unicast ip address-> No group joined.
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    create valid report
    Tg Create Single Tagged Stream On Port    tg1    report    service_p1    subscriber_p1    vlan_id=${p_match_vlan}    mac_src=${p_igmp_querier.mac}
    ...    vlan_user_priority=4    mac_dst=@{p_groups_mac_list}[0]    l3_protocol=ipv4    ip_src_addr=${p_igmp_host.ip}    ip_dst_addr=@{p_groups_list}[0]    l4_protocol=igmp
    ...    igmp_version=2    igmp_msg_type=report    igmp_group_addr=@{p_groups_list}[0]    igmp_multicast_addr=@{p_groups_list}[0]    length_mode=fixed    frame_size=250
    ...    transmit_mode=single_burst
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    log    delete the traffic
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    check the group
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    create the igmp report packet with invalid address
    Tg Create Single Tagged Stream On Port    tg1    report    service_p1    subscriber_p1    vlan_id=${p_match_vlan}    mac_src=${p_igmp_querier.mac}
    ...    vlan_user_priority=4    mac_dst=@{p_groups_mac_list}[0]    l3_protocol=ipv4    ip_src_addr=${p_igmp_host.ip}    ip_dst_addr=${invlalid_address}    l4_protocol=igmp
    ...    igmp_version=2    igmp_msg_type=report    igmp_group_addr=${invlalid_address}    igmp_multicast_addr=${invlalid_address}    length_mode=fixed    frame_size=250
    ...    transmit_mode=single_burst
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    log    should not show the invalid address in mcast group table
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    ${invlalid_address}    no
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
    &{dict_igmp_host}    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}
    ...    ${p_igmp_host.ip}    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
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
