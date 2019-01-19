*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Multi_flows_in_one_class_map_matched_upstream
   [Documentation]    1	create class-map with flow1 to match vlan 10 and flow2 to match vlan 20
    ...    2	create policy-map to bind class-map
    ...    3	add eth-port1 and eth-port2 to s-tag=100 with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1
    ...    5	send single-tagged VLAN=10 and VLAN=20 upstream traffics to ont1
    [Tags]    @author=AnneLI    @globalid=2298758    @tcid=AXOS_E72_PARENT-TC-648     @eut=NGPON2-4    @priority=P1   @jira=EXA-12566
    [Setup]    setup
    log    step5: send single-tagged VLAN ${match_vlan_2} and VLAN ${match_vlan4} upstream traffics to ont1to ${interface_type2} ${service_model.subscriber_point1.name} ;
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2    vlan_id=${match_vlan_2}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream2    p1    p2    vlan_id=${match_vlan_4}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac3}    mac_dst=${mac4}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
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
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${service_vlan} and vlan.id==${match_vlan_2}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p3    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${service_vlan} and vlan.id==${match_vlan_2}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_upstream2    p1    eth.src==${mac3} and eth.dst==${mac4} and vlan.id==${service_vlan} and vlan.id==${match_vlan_4}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_upstream2    p3    eth.src==${mac3} and eth.dst==${mac4} and vlan.id==${service_vlan} and vlan.id==${match_vlan_4}    ${error_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step3:add eth-port1 and eth-port2 to s-tag with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1:create class-map with flow ${flow_index} to match vlan ${match_vlan_2} and flow ${flow_index_1} to match vlan ${match_vlan_4}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${match_vlan_2}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index_1}    ${rule_index}
    ...    vlan=${match_vlan_4}
    log    step2:create a policy-map to bind the class-map
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index_1}
    log    step4:apply the s-tag and policy-map to the port of ont1
     subscriber_point_add_svc_user_defined    subscriber_point1     ${service_vlan}     ${policy_map_name}


teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${service_vlan}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
