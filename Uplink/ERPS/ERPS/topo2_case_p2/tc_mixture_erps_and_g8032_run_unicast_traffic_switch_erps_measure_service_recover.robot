*** Settings ***
Documentation     1.Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
...    2.Configure LAG between Node2 and Node 3 in Topo2
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***

*** Test Cases ***
tc_mixture_erps_and_g8032_run_unicast_traffic_switch_erps_measure_service_recover
    [Documentation]    1	Run unicast  traffic, Traffic run normally
    ...    2	switch erps	doesn't affect g8032 and services recover
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1313    @globalid=2319063    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Run unicast traffic Traffic run normally
    
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${smac}    mac_dst=${dmac}     rate_pps=${rate_pps}    l3_protocol=ipv4    ip_src_addr=${sip}    ip_dst_addr=${dip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63
    ...    mac_src_count=400    mac_src_mode=increment
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    subscriber_p1      service_p1    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${dmac}    mac_dst=${smac}
    ...    l3_protocol=ipv4    ip_src_addr=${dip}    ip_dst_addr=${sip}    l4_protocol=udp    rate_pps=${rate_pps}    mac_src_count=400    mac_src_mode=increment
    
    log    check traffic can pass without loss

    
    Tg Start All Traffic     tg1
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    tg_verify_traffic_loss_for_stream_is_within    tg1    raw_upstream1    ${ERPS_max_second_for_switch}
    tg_verify_traffic_loss_for_stream_is_within    tg1    raw_downstream1    ${ERPS_max_second_for_switch}

    log    STEP:2 switch erps, doesn't affect g8032 and services recover
    Tg Clear Traffic Stats    tg1
    # wait 5s to clear the traffic stats
    sleep    ${send_traffic_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    2 min    5 sec    check_interface_up    eutA    ethernet    ${service_model.service_point1.member.interface1}
    ${expect_max_pkts}    evaluate    ${rate_pps}*${ERPS_max_second_for_switch}

    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    TG Verify Traffic Statistics Are Less Than    tg1    dropped_pkts    ${expect_max_pkts}
    
*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes

    service_point_prov    service_point_list1
    service_point_prov    service_point_list5
    service_point_prov    service_point_list3
    
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1
    service_point_list_check_status_up    service_point_list5 
       
    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list5    ${service_vlan}
    service_point_add_vlan    service_point_list3    ${service_vlan}

    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


case teardown
    [Documentation]
    [Arguments]
    log    Enter teardown

    Tg Delete All Traffic    tg1
    
    log    remove service on ont-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_dprov    subscriber_point1

    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list5    ${service_vlan}
    service_point_remove_vlan    service_point_list3    ${service_vlan}

    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list5
    service_point_dprov    service_point_list3
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
    delete_config_object    eutB    vlan    ${service_vlan}
    delete_config_object    eutB    l2-dhcp-profile    ${dhcp_profile_name}