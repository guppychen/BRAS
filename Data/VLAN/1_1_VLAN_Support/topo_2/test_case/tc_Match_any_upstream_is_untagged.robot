*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Match_any_upstream_is_untagged
    [Documentation]    1.set vlan 100 mode as one2one
    ...    2.add eth-port1 and eth-port2 to VLAN 100 with transport-service-profile
    ...    3.apply VLAN 100 to ONT1
    ...    4.set (S;C) tags for ONT1 as (100;10)
    ...    5.send untagged upstream traffic to ONT1
    ...    6.send downstream traffic with (100;10) into eth-port1
    [Tags]    @globalid=2318795    @tcid=AXOS_E72_PARENT-TC-1150    @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    log    step5: send untagged upstream traffic to ${service_model.subscriber_point1.attribute.interface_type} ${service_model.subscriber_point1.name} with SMAC ${mac1} DMAC ${mac2};
    Tg Create Untagged Stream On Port    tg1    raw_upstream1    p1    p2    frame_size=512    length_mode=fixed
    ...    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    l4_protocol=udp
    ...    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
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
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${service_vlan} and vlan.id==${cvlan_one2one_1} and vlan.priority ==0 and vlan.priority ==0    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p3    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${service_vlan} and vlan.id==${cvlan_one2one_1} and vlan.priority ==0 and vlan.priority ==0    ${error_rate}
    log    step6: send downstream traffic with (${service_vlan};${cvlan_one2one_1}) into ${service_model.service_point1.attribute.interface_type} ${service_model.service_point1.member.interface1} with SMAC ${mac2} DMAC ${mac1};
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0
    ...    vlan_id=${cvlan_one2one_1}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    log    start traffic to lean mac on device
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p1
    start_capture    tg1    p2
    start_capture    tg1    p3
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p1
    stop_capture    tg1    p2
    stop_capture    tg1    p3
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${service_vlan} and vlan.id==${cvlan_one2one_1} and vlan.priority ==0 and vlan.priority ==0    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2    eth.src==${mac2} and eth.dst==${mac1}    ${error_rate}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac1} and eth.dst==${mac2}
    log    send downstream with unmatched S,C
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0
    ...    vlan_id=${cvlan_one2one_2}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac3}    mac_dst=${mac4}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    log    start traffic to lean mac on device
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
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
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${service_model.service_point1.attribute.interface_type}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p2    eth.src==${mac3} and eth.dst==${mac4}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: set vlan ${service_vlan} mode as one2one
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    log    step2: add ${service_model.service_point1.member.interface1} and ${service_model.service_point2.member.interface1} to VLAN ${service_vlan} with transport-service-profile
    service_point_add_vlan    service_point_list1    ${service_vlan}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    any=${EMPTY}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step3: apply VLAN ${service_vlan} to ONT1
    log    step4: set (S;C) tags for ONT1 as (${service_vlan};${cvlan_one2one_1})
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
