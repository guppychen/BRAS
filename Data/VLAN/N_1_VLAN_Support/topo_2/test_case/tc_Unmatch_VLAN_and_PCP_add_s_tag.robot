*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Unmatch_VLAN_and_PCP_add_s_tag
    [Documentation]    1	create a class-map to match VLAN 10 pcp 6 in flow 1
    ...    2	create a policy-map to bind the class-map
    ...    3	add eth-port1 and eth-port2 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1
    ...    5	send VLAN 20 PCP 6 upstream traffic to ont1
    ...    6	send VLAN 10 PCP 5 upstream traffic to ont1
    [Tags]    @author=AnneLI    @globalid=2298744   @tcid=AXOS_E72_PARENT-TC-634    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send vlan ${match_vlan} PCP ${match_pcp_1} upstream traffic to ${interface_type2} ${service_model.subscriber_point1.name} with SMAC ${mac1} DMAC ${mac2};
    log    step6: send vlan ${match_vlan_2} PCP ${match_pcp_2} upstream traffic to ${interface_type2} ${service_model.subscriber_point1.name} with SMAC ${mac3} DMAC ${mac4};
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2    vlan_id=${match_vlan}    vlan_user_priority=${match_pcp_1}
    ...    frame_size=512    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream2    p1    p2    vlan_id=${match_vlan_2}    vlan_user_priority=${match_pcp_2}
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
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac3} and eth.dst==${mac4}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac3} and eth.dst==${mac4}

    [Teardown]    teardown

*** Keywords ***
setup
   [Documentation]    setup
    clear_bridge_table    eutA
    log    step3:add eth-port1 and eth-port2 to s-tag with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1:create a class-map to match VLAN ${match_vlan_2} and PCP ${match_pcp_1} in flow ${flow_index}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${match_vlan_2}    pcp=${match_pcp_1}
    log    step2:create a policy-map to bind the class-map
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
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
