*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Multi_S_VLANs_under_an_ont_port_matched_downstream
    [Documentation]    1 create class-map1 to match vlan 10 and class-map2 to match vlan 20
    ...    2 create policy-map1 to bind class-map1 and policy-map2 to bind class-map2
    ...    3 add eth-port1 to s-tag1=100 and s-tag2=200 with transport-service-profile
    ...    4 apply the s-tag1 and policy-map1 to the port of ont1； apply the s-tag2 and policy-map2 to the port of ont1；
    ...    5 send double-tagged S=100 C=10 and S=200 C=20 downstream traffics to eth-port1
    [Tags]    @author=AnneLI    @globalid=2298756    @tcid=AXOS_E72_PARENT-TC-646     @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    log    step5: send double-tagged-tagged s=${service_vlan} c=${match_vlan_2} and s=${service_vlan_2} c=${match_vlan_4} downstream traffic to ${interface_type1} ${service_model.service_point1.member.interface1} ;
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream1    p2    p1    vlan_id=${match_vlan_2}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}    l4_protocol=udp    udp_dst_port=${udp_port2}    udp_src_port=${udp_port1}
    ...    rate_bps=${rate_bps}
    Tg Create Double Tagged Stream On Port    tg1    raw_downstream2    p2    p1    vlan_id=${match_vlan_4}    vlan_user_priority=0
    ...    vlan_id_outer=${service_vlan_2}    vlan_outer_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac4}    mac_dst=${mac3}
    ...    l3_protocol=ipv4    ip_src_addr=${ip4}    ip_dst_addr=${ip3}    l4_protocol=udp    udp_dst_port=${udp_port4}    udp_src_port=${udp_port3}
    ...    rate_bps=${rate_bps}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    log    clear tg port counters before start traffic
    Tg Clear Traffic Stats    tg1
    log    start capture on tg port before start traffic
    start_capture    tg1    p2
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    log    stop capture on tg port after stop traffic
    stop_capture    tg1    p2
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    log    verify traffic
    verify_traffic_loss_within_with_filter    tg1    raw_downstream1    p2    eth.src==${mac2} and eth.dst==${mac1} and vlan.id==${match_vlan_2}    ${error_rate}
    verify_traffic_loss_within_with_filter    tg1    raw_downstream2    p2    eth.src==${mac4} and eth.dst==${mac3} and vlan.id==${match_vlan_4}    ${error_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step3:add eth-port1 to s-tag1= ${service_vlan} and s-tag2= ${service_vlan_2} step3:add eth-port1 to s-tag1= ${service_vlan} and s-tag2= ${service_vlan_2}
    prov_vlan    eutA    ${service_vlan}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding    ENABLED    # Modified by AT-5444
    prov_vlan    eutA    ${service_vlan_2}
    prov_vlan_egress    eutA    ${service_vlan_2}    broadcast-flooding    ENABLED    # Modified by AT-5444
    prov_vlan_egress    eutA    ${service_vlan_2}    unknown-unicast-flooding    ENABLED    # Modified by AT-5444
    service_point_add_vlan    service_point_list1    ${service_vlan},${service_vlan_2}
    log    step1:create class-map1 to match vlan ${match_vlan_2} and class-map2 to match vlan ${match_vlan_4}}
    log    step2: create policy-map1 to bind class-map1 and policy-map2 to bind class-map2
    log    step4: apply the s-tag1 and policy-map1 to the port of ont1； apply the s-tag2 and policy-map2 to the port of ont1
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    subscriber_point_add_svc    subscriber_point1    ${match_vlan_2}    ${service_vlan}    cfg_prefix=auto1
    log    wait 5 because bug EXA-20231
    sleep    10
    subscriber_point_add_svc    subscriber_point1    ${match_vlan_4}    ${service_vlan_2}    cfg_prefix=auto2
    CLI    eutA    show running-config

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc    subscriber_point1    ${match_vlan_2}    ${service_vlan}    cfg_prefix=auto1
    log    wait 5 because bug EXA-20231
    sleep    5
    subscriber_point_remove_svc    subscriber_point1    ${match_vlan_4}    ${service_vlan_2}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan},${service_vlan_2}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan_2}
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    CLI    eutA    show running-config
