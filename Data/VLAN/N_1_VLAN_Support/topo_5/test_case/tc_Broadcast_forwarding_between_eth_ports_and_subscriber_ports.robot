*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Broadcast_forwarding_between_eth_ports_and_subscriber_ports
    [Documentation]    1	create a class-map to match untagged in flow 1
    ...    2	create a policy-map to bind the class-map
    ...    3	add eth-port1 and eth-port2 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    5	send untagged upstream traffic to ont1 with SMAC 000001000001 DMAC FFFFFFFFFFFF;	both eth-port1 and eth-port2 can receive the upstream traffic
    ...    6	send s-tag downstream traffic to eth-port1 with SMAC 000002000002 DMAC FFFFFFFFFFFF
    [Tags]    @author=AnneLI    @globalid=2298766       @tcid=AXOS_E72_PARENT-TC-656     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send untagged upstream traffic to ont-port ${service_model.subscriber_point1.name} with SMAC ${mac1} DMAC ${mac_broadcast};
    TG Create Untagged Stream On Port    tg1    raw_upstream1    p1    p3    frame_size=512    length_mode=fixed
    ...    mac_src=${mac1}    mac_dst=${mac_broadcast}    l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    l4_protocol=udp
    ...    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
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
    show_interface_counters    eutA     ${interface_type1}     ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA     ${interface_type1}     ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA     ${interface_type2}     ${service_model.subscriber_point1.name}
    show_interface_counters    eutA     ${interface_type2}     ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p1    eth.src==${mac1} and vlan.id == ${service_vlan}   ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p2    eth.src==${mac1} and vlan.id == ${service_vlan}   ${error_rate}
    Tg Delete All Traffic    tg1
    log    step6: send s-tag downstream traffic from eth-port ${service_model.service_point1.member.interface1} with SMAC ${mac2} DMAC ${mac_broadcast};
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p3    p1      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac_broadcast}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p3
    start_capture    tg1    p4
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p3
    stop_capture    tg1    p4
    log    show interface counters after stop traffic
    show_interface_counters    eutA     ${interface_type1}     ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA     ${interface_type1}     ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA     ${interface_type2}     ${service_model.subscriber_point1.name}
    show_interface_counters    eutA     ${interface_type2}     ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p3    eth.src==${mac2}     ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p4    eth.src==${mac2}     ${error_rate}

    [Teardown]    teardown

*** Keywords ***
setup
   [Documentation]    setup
    clear_bridge_table    eutA
    log    step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding    ENABLED    # Modified by AT-5444
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1: create a class-map to match untagged in flow 1
    log    step2: create a policy-map to bind the class-map
    log    step4: apply the s-tag and policy-map to the port of ont1
    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    untagged    ${service_vlan}    cfg_prefix=auto2
teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}     cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    untagged    ${service_vlan}     cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
