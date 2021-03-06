*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Multi_S-VLANs_under_an_ont-port_unmatched_upstream
    [Documentation]    1	set vlan 100 and 200 mode as one2one
    ...    2    add eth-port1 and eth-port2 to VLAN 100 and 200 with transport-service-profile
    ...    3    apply VLAN 100 and 200 to ONT1
    ...    4    set (S;C) tags for ONT1 as (100;10) and (200;20)
    ...    5    send single-tagged upstream traffic to ONT1; but the traffic does not match the rules in classmap

    [Tags]    @globalid=2318798    @tcid=AXOS_E72_PARENT-TC-1153    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5:send single-tagged upstream traffic to ONT
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2    vlan_id=${match_vlan_3}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream2    p1    p2    vlan_id=${match_vlan_4}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac3}    mac_dst=${mac4}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p1
    start_capture    tg1    p3
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p1
    stop_capture    tg1    p3
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac3} and eth.dst==${mac4}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: set vlan ${service_vlan_1} mode as one2one, vlan ${service_vlan_2} mode as one2one
    prov_vlan    eutA    ${service_vlan_1}    mode=ONE2ONE
    prov_vlan    eutA    ${service_vlan_2}    mode=ONE2ONE
    log    step2: add ${service_model.service_point1.member.interface1} and ${service_model.service_point2.member.interface1} to VLAN with transport-service-profile
    service_point_add_vlan    service_point_list1    ${service_vlan_1},${service_vlan_2}
    prov_class_map    eutA    ${class_map_name_1}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${match_vlan_1}
    prov_class_map    eutA    ${class_map_name_2}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${match_vlan_2}
    prov_policy_map    eutA    ${policy_map_name_1}    class-map-ethernet    ${class_map_name_1}    sub_view_type=flow    sub_view_value=${flow_index}
    prov_policy_map    eutA    ${policy_map_name_2}    class-map-ethernet    ${class_map_name_2}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step3: apply VLAN to ONT1
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan_1}    ${cvlan_one2one_1}    ${policy_map_name_1}
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan_2}    ${cvlan_one2one_2}    ${policy_map_name_2}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan_1}    ${cvlan_one2one_1}    ${policy_map_name_1}
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan_2}    ${cvlan_one2one_2}    ${policy_map_name_2}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan_1},${service_vlan_2}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan_1}
    delete_config_object    eutA    vlan    ${service_vlan_2}
    delete_config_object    eutA    policy-map    ${policy_map_name_1}
    delete_config_object    eutA    policy-map    ${policy_map_name_2}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name_1}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name_2}
