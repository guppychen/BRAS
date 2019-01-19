*** Settings ***
Documentation     1.Configure an ERPS ring with three nodes
...    2.Configure data service through erps ring
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo1_run_unknown_unicast_traffic_do_erps_switch_measure_switch_time_and_service_recover
    [Documentation]    1	run l2 unkown traffic using STC with 400 mac Verify traffic flow between each node.
    ...    2	disable forwarding interface on master node	traffis loss <1s,and noop
    ...    3	show erps ring status	Correct
    ...    4	enable interface	alarm cleared ,and erps-domain switchback , traffic loss <1s,and no loop
    ...    5	show erps ring status	Recover
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1262    @globalid=2319012    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 run l2 unkown traffic using STC with 400 mac Verify traffic flow between each node.
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${smac}    mac_dst=${dmac}     rate_pps=${rate_pps}    l3_protocol=ipv4    ip_src_addr=${sip}    ip_dst_addr=${dip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63
    ...    mac_src_count=400    mac_src_mode=increment
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    subscriber_p1      service_p1    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${dmac}    mac_dst=${smac}
    ...    l3_protocol=ipv4    ip_src_addr=${dip}    ip_dst_addr=${sip}    l4_protocol=udp    rate_pps=${rate_pps}    mac_src_count=400    mac_src_mode=increment

    log    STEP:2 disable forwarding interface on master node traffis loss <1s,and noop

    Tg Start All Traffic    tg1
    log     send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    log     send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log     stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    tg_verify_traffic_loss_for_stream_is_within    tg1    raw_upstream1    ${ERPS_max_second_for_switch}
    tg_verify_traffic_loss_for_stream_is_within    tg1    raw_downstream1    ${ERPS_max_second_for_switch}

    log    STEP:3 show erps ring status Correct
    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    secondary-interface-fwd-state=forwarding

    log    STEP:4 enable interface alarm cleared ,and erps-domain switchback , traffic loss <1s,and no loop
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}

    log    STEP:5 show erps ring status Recover
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    primary-interface-fwd-state=forwarding


*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure two ERPS rings with three nodes
    
    service_point_prov    service_point_list1
    service_point_prov    service_point_list2

    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}


    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    remove service on ont-port
    
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    deprovision subscriber
    subscriber_point_dprov    subscriber_point1
    
    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2   ${service_vlan}

    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2


    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}


