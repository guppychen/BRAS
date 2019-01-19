*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Multi_rules_in_one_flow_un_matched_downstream
  [Documentation]    1	create class-map with flow1 to match vlan 10 in rule1 and match vlan 20 in rule2
    ...    2	create policy-map to bind class-map
    ...    3	add eth-port1 to s-tag=100 with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    5	send double-tagged S=100 C=30 and S=100 C=40 downstream traffics to eth-port1    no clients can receive the traffics
    [Tags]    @author=AnneLI    @globalid=2298765    @tcid=AXOS_E72_PARENT-TC-655     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
     log    step5: send double-tagged S=${service_vlan} C=${match_vlan} and S=${service_vlan} C=${match_vlan_3} downstream traffics to ${interface_type1} ${service_model.service_point1.member.interface1};
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id=${match_vlan}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream2    p2    p1    vlan_id=${match_vlan_3}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac4}    mac_dst=${mac3}
    ...    l3_protocol=ipv4    ip_src_addr=${ip4}    ip_dst_addr=${ip3}    l4_protocol=udp    udp_dst_port=${udp_port4}    udp_src_port=${udp_port2}
    ...    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p2
    start_capture    tg1    p3
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p2
    stop_capture    tg1    p3
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac2} and eth.dst==${mac1}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac4} and eth.dst==${mac3}

    [Teardown]    teardown
*** Keywords ***
setup
   [Documentation]    setup
    clear_bridge_table    eutA
    log    step3:add eth-port1 to s-tag=100 with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1:create class-map with flow ${flow_index} to match vlan ${match_vlan_2} in rule ${rule_index} and match vlan ${match_vlan_4} in rule ${rule_index_1}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${match_vlan_2}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index_1}
    ...    vlan=${match_vlan_4}
    log    step2:create a policy-map to bind the class-map
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step4:apply the s-tag and policy-map to the port of ont1 and ont2
    subscriber_point_add_svc_user_defined    subscriber_point1     ${service_vlan}     ${policy_map_name}
    subscriber_point_add_svc_user_defined    subscriber_point2     ${service_vlan}     ${policy_map_name}
    CLI    eutA    show running-config

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${service_vlan}    ${policy_map_name}
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${service_vlan}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    CLI    eutA    show running-config

