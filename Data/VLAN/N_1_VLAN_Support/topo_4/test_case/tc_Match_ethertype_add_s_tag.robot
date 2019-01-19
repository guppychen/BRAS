*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Match_ethertype_add_s_tag
    [Documentation]    1	create a class-map to match ethertype arp in flow 1
    ...    2	create a policy-map to bind the class-map
    ...    3	add eth-port1 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    5	send double-tagged downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001;	both client1 and client2 can receive the downstream traffic;
    ...    6	send ethertype arp upstream traffic to ont1 with SMAC 000001000001 DMAC 000002000002;	eth-port1 can pass the upstream traffic; only client1 can receive the downstream traffic;
    [Tags]    @author=AnneLI    @globalid=2298734    @tcid=AXOS_E72_PARENT-TC-624     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send double-tagged downstream traffic to ${interface_type1} ${service_model.service_point1.member.interface1},with SMC ${mac2} DMC ${mac1};
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id=${cvlan}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
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
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2    eth.src==${mac2} and eth.dst==${mac1}     ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p3    eth.src==${mac2} and eth.dst==${mac1}      ${error_rate}
    log    step6: send ethertype arp upstream traffic to ${interface_type2} ${service_model.subscriber_point1.name} with SMAC ${mac1} DMAC ${mac2}
    TG Create Untagged Stream On Port    tg1    raw_upstream1    p1    p2    frame_size=512    length_mode=fixed
    ...    mac_src=${mac1}    mac_dst=${mac2}     ether_type=0806    rate_bps=${rate_bps}
    log    start traffic to lean mac on device
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
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
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and eth.dst==${mac2} and vlan.id==${cvlan} and vlan.id==${service_vlan}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2    eth.src==${mac2} and eth.dst==${mac1}    ${error_rate}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac2} and eth.dst==${mac1}
    [Teardown]    teardown
*** Keywords ***
setup
     [Documentation]    setup
     clear_bridge_table    eutA
     log     step3: add eth-port1 to s-tag with transport-service-profile
     prov_vlan    eutA    ${service_vlan}
     prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
     prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding    ENABLED    # Modified by AT-5444
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match ethertype arp in flow ${flow_index}
     prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
     ...    ethertype=arp
     log     step2: create a policy-map to bind the class-map
     prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}     add-cevlan-tag=${cvlan}
     log     step4: apply the s-tag and policy-map to the port of ont1 and ont2
     subscriber_point_add_svc_user_defined    subscriber_point1    ${service_vlan}    ${policy_map_name}
     subscriber_point_add_svc_user_defined    subscriber_point2    ${service_vlan}    ${policy_map_name}
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
    log    delete vlan class-police and policy-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    CLI    eutA    show running-config



