*** Settings ***
Documentation     1.Configure an ERPS ring with three nodes
...    2.Configure data service
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo2_Modify_control_vlan_measure_services_recovery
    [Documentation]    1	Modify control-vlan of erps-ring	service recover
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1318    @globalid=2319068    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Modify control-vlan of erps-ring service recover
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan_1}

    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutC    2

    log  check service recover
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${smac}    mac_dst=${dmac}     rate_pps=${rate_pps}    l3_protocol=ipv4    ip_src_addr=${sip}    ip_dst_addr=${dip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63
    ...    mac_src_count=400    mac_src_mode=increment
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    subscriber_p1      service_p1    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${dmac}    mac_dst=${smac}
    ...    l3_protocol=ipv4    ip_src_addr=${dip}    ip_dst_addr=${sip}    l4_protocol=udp    rate_pps=${rate_pps}    mac_src_count=400    mac_src_mode=increment

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


*** Keywords ***
case setup
    [Documentation]
    [Arguments]

    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    service_point_prov    service_point_list3
    
    
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1
    service_point_list_check_status_up    service_point_list2
    
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
    service_point_add_vlan    service_point_list2    ${service_vlan}
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
    service_point_remove_vlan    service_point_list2    ${service_vlan}
    service_point_remove_vlan    service_point_list3    ${service_vlan}

    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    service_point_dprov    service_point_list3
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
    delete_config_object    eutB    vlan    ${service_vlan}
    delete_config_object    eutB    l2-dhcp-profile    ${dhcp_profile_name}