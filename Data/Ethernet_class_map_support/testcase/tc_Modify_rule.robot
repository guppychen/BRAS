*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Ethernet Class Map      @author=MinGu

*** Variables ***
${modify_rule_vlan}    4009

*** Test Cases ***
tc_Modify_rule
    [Documentation]

    ...    1	create a class-map to match VLAN 10 in flow 1	successfully
    ...    2	create a policy-map to bind the class-map	successfully
    ...    3	add eth-port1 to s-tag with transport-service-profile	successfully
    ...    4	apply the s-tag and policy-map to the port of ethernet uni	successfully
    ...    5	send VLAN 10 upstream traffic to uni port	both eth-port1 can pass the upstream traffic
    ...    6	send double-tagged downstream traffic to eth-port1	client1 can receive the downstream traffic;
    ...    7	Modify the rule in class map to match another VLAN	successfully. The traffic does not work
    ...    8	Modify the rule to match VLAN 10 again	successfully. The traffic can work with right tag.


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4349      @subFeature=10GE-12: Ethernet class map support      @globalid=2531536      @priority=P1      @eut=10GE-12          @user_interface=CLI
    [Setup]     case setup
    [Teardown]     case teardown
    log    STEP:5 send VLAN 10 upstream traffic to uni port both eth-port1 can pass the upstream traffic
    create_raw_traffic_udp    tg1    match_vlan_us    service_p1    subscriber_p1    ${match_vlan}
    ...    mac_dst=${tg_server.mac}    mac_src=${tg_client.mac}    ip_dst=${tg_server.ip}    ip_src=${tg_client.ip}    rate_mbps=${pkt_rate}

    log    STEP:6 send double-tagged downstream traffic to eth-port1 client1 can receive the downstream traffic;
    create_raw_traffic_udp    tg1    double_tag_ds    subscriber_p1    service_p1    ${service_vlan_1}    ${match_vlan}
    ...    mac_dst=${tg_client.mac}    mac_src=${tg_server.mac}    ip_dst=${tg_client.ip}    ip_src=${tg_server.ip}    rate_mbps=${pkt_rate}

    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

    ${save_file_service_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    sleep    10s    Wait for save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}

    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (vlan.id==${service_vlan_1}) && (vlan.id==${match_vlan}) && (eth.src==${tg_client.mac}) && (eth.dst==${tg_server.mac}) && (ip.src == ${tg_client.ip}) && (ip.dst == ${tg_server.ip})

    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (vlan.id==${match_vlan}) && (eth.src==${tg_server.mac}) && (eth.dst==${tg_client.mac}) && (ip.src == ${tg_server.ip}) && (ip.dst == ${tg_client.ip})

    log    STEP:7 Modify the rule in class map to match another VLAN successfully. The traffic does not work
    dprov_class_map    eutA    &{dict_prf}[classmap]    ${class_map_type}    flow    ${flow_index}    rule=1
    prov_class_map    eutA    &{dict_prf}[classmap]    ${class_map_type}    flow    ${flow_index}    ${rule_index}    vlan=${modify_rule_vlan}
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    stop_capture    tg1    service_p1
    verify_traffic_stream_all_pkt_loss    tg1    match_vlan_us


    log    STEP:8 Modify the rule to match VLAN 10 again successfully. The traffic can work with right tag.
    dprov_class_map    eutA    &{dict_prf}[classmap]    ${class_map_type}    flow    ${flow_index}    rule=1
    prov_class_map    eutA    &{dict_prf}[classmap]    ${class_map_type}    flow    ${flow_index}    ${rule_index}    vlan=${match_vlan}
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

    ${save_file_service_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    sleep    10s    Wait for save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}

    analyze_packet_count_greater_than    ${save_file_service_p1}
    ...    (vlan.id==${service_vlan_1}) && (vlan.id==${match_vlan}) && (eth.src==${tg_client.mac}) && (eth.dst==${tg_server.mac}) && (ip.src == ${tg_client.ip}) && (ip.dst == ${tg_server.ip})

    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    (vlan.id==${match_vlan}) && (eth.src==${tg_server.mac}) && (eth.dst==${tg_client.mac}) && (ip.src == ${tg_server.ip}) && (ip.dst == ${tg_client.ip})


*** Keywords ***
case setup
    [Documentation]    setup
    log     STEP:1 create a class-map to match VLAN 4001 in flow 1
    log     STEP:2 create a policy-map to bind the class-map
    log     STEP:3 add eth-port1 to s-tag with transport-service-profile (done in suite_setup)
    log     STEP:4 apply the s-tag and policy-map to the port of ethernet uni
    &{dict_prf}    subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan_1}
    Set Suite Variable    &{dict_prf}

case teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan_1}
