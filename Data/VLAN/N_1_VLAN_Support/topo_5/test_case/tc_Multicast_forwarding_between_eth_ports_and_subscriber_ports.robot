*** Settings ***
Documentation
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Multicast_forwarding_between_eth_ports_and_subscriber_ports
    [Documentation]    1	create a class-map to match VLAN in flow 1
    ...    2	create a policy-map to bind the class-map； remove-cevlan
    ...    3	add eth-port1 and eth-port2 to s-tag with transport-service-profile
    ...    4	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    5	send s-tag downstream Multicast traffic to eth-port1； the traffic contains a UDP payload
    [Tags]    @author=AnneLI    @globalid=2298767      @tcid=AXOS_E72_PARENT-TC-657     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step6 send s-tag downstream Multicast traffic to to ${interface_type1} ${service_model.service_point1.member.interface1}； the traffic contains a UDP payload
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p3    p1      vlan_id=${service_vlan}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac_multicast}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip_multicast}
    ...    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    tg save config into file   tg1   /tmp/${TEST NAME}.xml

    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p2
    start_capture    tg1    p3
    start_capture    tg1    p4
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p2
    stop_capture    tg1    p3
    stop_capture    tg1    p4
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2    eth.src==${mac2} and eth.dst==${mac_multicast} and vlan.id == ${service_vlan}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p3    eth.src==${mac2} and eth.dst==${mac_multicast} and vlan.id == ${match_vlan}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p4    eth.src==${mac2} and eth.dst==${mac_multicast} and vlan.id == ${match_vlan}    ${error_rate}

    [Teardown]    teardown
*** Keywords ***
setup
     [Documentation]    setup
     clear_bridge_table    eutA
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN ${match_vlan} in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}       ${service_vlan}         cevlan_action=remove-cevlan     cfg_prefix=auto1
     subscriber_point_add_svc    subscriber_point2      ${match_vlan}       ${service_vlan}         cevlan_action=remove-cevlan     cfg_prefix=auto2

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}     cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2      ${match_vlan}     ${service_vlan}     cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}

