*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Match_any_add_s_tag_upstream_is_1024_DMACs
    [Documentation]    1	create a class-map to match any in flow 1
    ...    2	create a policy-map to bind the class-map
    ...    3	add eth-port1 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    5	send single-tagged downstream traffic to eth-port1 with 1024 SMACs starts from 000002000002 and the number is 1024; DMAC is 000001000001
    ...    6	send untagged upstream traffic to ont1 with 1024 DMACs starts from 000002000002 and the number is 1024; SMAC is 000001000001
    [Tags]    @author=AnneLI    @globalid=2298740    @tcid=AXOS_E72_PARENT-TC-630   @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send single-tagged downstream traffic to ${interface_type1} ${service_model.service_point1.member.interface1} with 1024 SMACs starts from ${mac2} and the number is 1024; DMAC is ${mac1} ;
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p2    p1      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac2}    mac_src_count=1024    mac_src_mode=increment     mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}
    ...    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}

    Tg Control Traffic   tg1    raw_downstream1    run     enable_arp=0

#    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
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
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2     eth.dst==${mac1}     ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p3     eth.dst==${mac1}      ${error_rate}
    log    step6: send untagged upstream traffic to ${interface_type2} ${service_model.subscriber_point1.name} with DMACs starts from ${mac2} and the number is 1024; SMAC is ${mac1}
    TG Create Untagged Stream On Port    tg1    raw_upstream1    p1    p2    frame_size=512    length_mode=fixed
    ...    mac_src=${mac1}    mac_dst=${mac2}    mac_dst_count=1024    mac_dst_mode=increment  l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    l4_protocol=udp
    ...    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    log    start traffic to lean mac on device
    tg save config into file   tg1   /tmp/${TEST NAME}.xml

#    Tg Start All Traffic    tg1
    Tg Control Traffic   tg1    raw_downstream1    run     enable_arp=0

    Tg Control Traffic   tg1    raw_upstream1   run     enable_arp=0

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
    # as CTPT-118, arp not disabled, so add filter udp for the case
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and vlan.id==${service_vlan} and udp    ${error_rate}

    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2     eth.dst==${mac1} and udp    ${error_rate}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.dst==${mac1}

    [Teardown]    teardown


*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step3:add eth-port1 to s-tag=100 with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding    ENABLED    # Modified by AT-5444
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1:create class-map to match any in flow ${flow_index} }
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    any=${EMPTY}
    log    step2:create a policy-map to bind the class-map
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step4:apply the s-tag and policy-map to the port of ont1 and ont2
    subscriber_point_add_svc_user_defined    subscriber_point1     ${service_vlan}     ${policy_map_name}
    subscriber_point_add_svc_user_defined    subscriber_point2     ${service_vlan}      ${policy_map_name}
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



