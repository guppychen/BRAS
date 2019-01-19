*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Storm_control_for_multicast
    [Documentation]    1	set strorm control multicast rate 1000pps for eth-port1
    ...    2	send multicast traffic 2000pps into eth-port1
    [Tags]    @author=Lincoln Yu    @globalid=2384307    @tcid=AXOS_E72_PARENT-TC-2919    @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    p2    p1    vlan_id=${service_vlan}    vlan_user_priority=0
    ...    frame_size=512    length_mode=fixed    mac_src=${mac1}    mac_dst=${multicast_mac}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...    ip_dst_addr=${ip2}    l4_protocol=udp    udp_dst_port=${udp_port1}    udp_src_port=${udp_port2}    rate_pps=${rate_pps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
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
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point2.member.interface1}
    log    verify traffic
    ${res}    Run Keyword And Ignore Error    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p2    eth.src==${mac1} and eth.dst==${broadcast_mac} and vlan.id==${service_vlan} and vlan.priority ==0
    ...    ${limit_rate_low}
    should contain    ${res[0]}    FAIL
    verify_traffic_loss_within_with_filter    tg1    raw_upstream1    p2    eth.src==${mac1} and eth.dst==${multicast_mac} and vlan.id==${service_vlan} and vlan.priority ==0    ${limit_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    prov_vlan    eutA    ${service_vlan}
    log    add ${service_model.service_point1.member.interface1} and ${service_model.service_point2.member.interface1} to VLAN ${service_vlan} with transport-service-profile
    service_point_add_vlan    service_point_list1    ${service_vlan}
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    storm-control multicast=${storm_control_rate}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    dprov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    storm-control multicast
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
