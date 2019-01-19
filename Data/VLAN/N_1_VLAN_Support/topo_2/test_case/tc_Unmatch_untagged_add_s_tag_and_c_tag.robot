*** Settings ***
Suite Setup
Suite Teardown
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Unmatch_untagged_add_s_tag_and_c_tag
    [Documentation]    1	create a class-map to match untagged in flow 1
    ...    2	create a policy-map to bind the class-map and c-tag=10
    ...    3	add eth-port1 and eth-port2 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1
    ...    5	send priority-tagged upstream traffic to ont1	no eth-port can pass the upstream traffic
    ...    6	send single tagged downstream traffic to eth-port1	no client can receive the downstream traffic
    ...    7	send double tagged downstream traffic to eth-port1 with c-tag=20	no client can receive the downstream traffi
    [Tags]    @author=AnneLI     @globalid=2298742       @tcid=AXOS_E72_PARENT-TC-632     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step5: send priority-tagged upstream traffic to ont-port ${service_model.subscriber_point1.name} with SMAC ${mac1} DMAC ${mac2};
    log    step6: send single-tagged downstream traffic to eth-port ${service_model.service_point1.member.interface1} with SMAC ${mac2} DMAC ${mac1};
    log    step7: send double-tagged downstream traffic to eth-port ${service_model.service_point1.member.interface1} with SMAC ${mac2} DMAC ${mac1} and c-tag=${cvlan_2}
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p1    p2      vlan_id=0    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}
    ...    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p2    p1      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}
    ...    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream2    p2    p1    vlan_id=${cvlan_2}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
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
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_no_traffic_on_port_with_filter    tg1    p1    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p3    eth.src==${mac1} and eth.dst==${mac2}
    verify_no_traffic_on_port_with_filter    tg1    p2    eth.src==${mac2} and eth.dst==${mac1}

    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    step1: create a class-map to match untagged in flow 1
    log    step2: create a policy-map to bind the class-map and add c-tag
    log    step4: apply the s-tag and policy-map to the port of ont1
    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}    ctag_action=add-cevlan-tag    cvlan=${cvlan}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    subscriber_point remove_vlan and deprovision
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}    ${cvlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
