*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Multi_rules_in_one_flow_unmatched_downstream
    [Documentation]    1	set vlan 100 mode as one2one
    ...    2    add eth-port1 and eth-port2 to VLAN 100 with transport-service-profile
    ...    3    match vlan 10 for rule1 and vlan 20 for rule2
    ...    4    set (S;C) tags for ONT1 as (100;10)
    ...    5    send downstream traffic with (100;20) into eth-port1

    [Tags]    @globalid=2318808    @tcid=AXOS_E72_PARENT-TC-1163    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5:send downstream traffic with (100;20)
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id_other=${service_vlan_1}    vlan_user_priority_other=0
    ...    vlan_id_outer=${cvlan_one2one_2}    vlan_outer_user_priority=0    vlan_id=${match_vlan_1}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${mac2}    mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp
    ...    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream2    p2    p1    vlan_id_other=${service_vlan_1}    vlan_user_priority_other=0
    ...    vlan_id_outer=${cvlan_one2one_2}    vlan_outer_user_priority=0    vlan_id=${match_vlan_2}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${mac4}    mac_dst=${mac3}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp
    ...    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type }    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type }    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p1
    start_capture    tg1    p2
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p1
    stop_capture    tg1    p2
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type }    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type }    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p2    eth.src==${mac2} and eth.dst==${mac1}
    verify_no_traffic_on_port_with_filter    tg1    p2    eth.src==${mac4} and eth.dst==${mac3}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: set vlan ${service_vlan_1} mode as one2one
    prov_vlan    eutA    ${service_vlan_1}    mode=ONE2ONE
    log    step2: add ${service_model.service_point1.member.interface1} and ${service_model.service_point2.member.interface1} to VLAN with transport-service-profile
    service_point_add_vlan    service_point_list1    ${service_vlan_1}
    prov_class_map    eutA    ${class_map_name_1}    ${class_map_type}    flow    ${flow_index}    ${rule_index_1}
    ...    vlan=${match_vlan_1}
    prov_class_map    eutA    ${class_map_name_1}    ${class_map_type}    flow    ${flow_index}    ${rule_index_2}
    ...    vlan=${match_vlan_2}
    prov_policy_map    eutA    ${policy_map_name_1}    class-map-ethernet    ${class_map_name_1}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step3: apply VLAN to ONT1
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan_1}    ${cvlan_one2one_1}    ${policy_map_name_1}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan_1}    ${cvlan_one2one_1}    ${policy_map_name_1}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan_1}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan_1}
    delete_config_object    eutA    policy-map    ${policy_map_name_1}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name_1}
