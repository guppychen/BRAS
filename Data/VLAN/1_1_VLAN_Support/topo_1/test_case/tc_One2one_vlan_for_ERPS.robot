*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_One2one_vlan_for_ERPS
    [Documentation]    1 set vlan 100 mode as one2one and enable mac learning on E7-A and E7-B
    ...    2 provision ERPS between two E7s;
    ...    3 add vlan 100 to ERPS ring ports on both E7s; add uplink to vlan 100 on E7-B
    ...    4 send unstream and downstream traffics
    ...    5 switch the ring
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1178    @globalid=2318823    @priority=P2    @eut=NGPON2-4
    [Setup]    case setup
    Tg Create Untagged Stream On Port    tg1    upstream    p1    p2    frame_size=512    length_mode=fixed
    ...    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    l4_protocol=udp
    ...    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    Tg Create Double Tagged Stream On Port    tg1    downstream    p2    p1    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0
    ...    vlan_id=${cvlan_one2one_1}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    clear_interface_counters    eutA    ${service_model.service_point3.attribute.interface_type}    ${service_model.service_point3.member.interface1}
    clear_interface_counters    eutB    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    shutdown_port    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${ERPS_max_second_for_switch}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${ERPS_max_second_for_switch}
    [Teardown]    case teardown

*** Keywords ***
case setup
    [Documentation]    setup
    clear_bridge_table    eutA
    clear_bridge_table    eutB
    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    log    step1: set vlan ${service_vlan} mode as one2one
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    prov_vlan    eutB    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}
    prov_class_map    eutB    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    untagged=${EMPTY}
    prov_policy_map    eutB    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}

case teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutB    vlan    ${service_vlan}
    delete_config_object    eutB    policy-map    ${policy_map_name}
    delete_config_object    eutB    class-map    ${class_map_type} ${class_map_name}
