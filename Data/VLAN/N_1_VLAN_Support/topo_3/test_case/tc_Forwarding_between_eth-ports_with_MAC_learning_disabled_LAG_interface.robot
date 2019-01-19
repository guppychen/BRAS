*** Settings ***
Documentation
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Forwarding_between_eth-ports_with_MAC_learning_disabled_LAG_interface
    [Documentation]   1.create LAG interface with eth-port1 and eth-port2;
    ...    2 add eth-port3 eth-port4 and LAG interface to the same transport-service-profile.
    ...    3 disable mac learning in the outer S-vlan
    ...    3 send single-tagged traffic into eth-port3 with SMAC 000001000001 DMAC 000002000002;	the traffic can be received from both eth-port4 and LAG
    ...    4 send single-tagged traffic into LAG with SMAC 000002000002 DMAC 000001000001;	the traffic can be received from both eth-port4 and LAG
    ...    5 show bridge table	 No MAC learned in S-VLAN


    [Tags]    @author=AnneLI    @globalid=2298713      @tcid=AXOS_E72_PARENT-TC-603       @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step4: send single-tagged traffic into ${service_model.service_point2.member.interface1} with SMAC ${mac1} DMAC ${mac2};
    Tg Create single Tagged Stream On Port    tg1    raw_stream1    p1    p2      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}    ip_dst_addr=${ip2}
    ...    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point3.member.interface1}
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
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point3.member.interface1}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_stream1    p1    eth.src==${mac1} and eth.dst==${mac2}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_stream1    p3    eth.src==${mac1} and eth.dst==${mac2}    ${error_rate}
    log    step5: send single-tagged traffic into lag with SMAC ${mac2} DMAC ${mac1};
    Tg Create single Tagged Stream On Port    tg1    raw_stream2    p2    p1      vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512
    ...    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}
    ...    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    log    start traffic to lean mac on device
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    sleep    ${stop_traffic_time}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point3.member.interface1}
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
    log    step6: show bridge table
    check_no_bridge_table_by_mac    eutA    ${mac1}
    check_no_bridge_table_by_mac    eutA    ${mac2}
    log    step5: capture packtes on ${service_model.service_point3.member.interface1}
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point3.member.interface1}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_stream2    p2    eth.src==${mac2} and eth.dst==${mac1}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_stream1    p1    eth.src==${mac1} and eth.dst==${mac2}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_stream1    p3    eth.src==${mac1} and eth.dst==${mac2}    ${error_rate}


    [Teardown]    teardown

*** Keywords ***
setup
     [Documentation]    setup
     clear_bridge_table    eutA
     log     step1: create LAG interface with eth-port1
     log     step2: add eth-port3 eth-port4 and LAG interface to the same transport-service-profile.
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step3: disable mac learning in the outer S-vlan
     prov_vlan    eutA    ${service_vlan}     mac-learning=DISABLED

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    dprov_vlan    eutA    ${service_vlan}    mac-learning
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}























