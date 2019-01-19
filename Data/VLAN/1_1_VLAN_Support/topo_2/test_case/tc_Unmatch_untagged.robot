*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Unmatch_untagged
    [Documentation]    1.set vlan 100 mode as one2one
    ...    2.add eth-port1 and eth-port2 to VLAN 100 with transport-service-profile
    ...    3.create policy to match VLAN
    ...    4.set (S;C) tags for ONT1 as (100;10)
    ...    5.send priority-tagged upstream traffic to ont1
    ...    6.send single tagged = 10 upstream traffic to ont1
    [Tags]    @globalid=2318809    @tcid=AXOS_E72_PARENT-TC-1164    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send priority-tagged upstream traffic to ${service_model.subscriber_point1.attribute.interface_type} ${service_model.subscriber_point1.name}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2    vlan_id=0    vlan_user_priority=0    frame_size=512    length_mode=fixed
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
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac1} and eth.dst==${mac2}

    log    step6: send single tagged = ${match_vlan_2} traffic to ${service_model.subscriber_point1.attribute.interface_type} ${service_model.subscriber_point1.name}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2    vlan_id=${match_vlan_2}    vlan_user_priority=0    frame_size=512    length_mode=fixed
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
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac1} and eth.dst==${mac2}
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
    ...    untagged=${EMPTY}
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
