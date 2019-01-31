*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Ethernet Class Map      @author=MinGu

*** Variables ***
${class_map_num}    2


*** Test Cases ***
tc_Multi_S_VLANs_under_an_uni_matched_upstream
    [Documentation]

     ...    1	create class-map1 to match vlan 10 and class-map2 to match vlan 20
    ...    2	create policy-map1 to bind class-map1 and policy-map2 to bind class-map2
    ...    3	add eth-port1 to s-tag1=100 and s-tag2=200 with transport-service-profile
    ...    4	apply the s-tag1 and policy-map1 to the uni port； apply the s-tag2 and policy-map2 to the uni port；
    ...    5	send single-tagged=10 and 20 upstream traffic to uni port	eth-port1 can pass traffics with S=100 C=10 and S=200 C=20


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4347      @subFeature=10GE-12: Ethernet class map support      @globalid=2531534      @priority=P1      @eut=10GE-12          @user_interface=CLI
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:5 send single-tagged=10 and 20 upstream traffic to uni port eth-port1 can pass traffics with S=100 C=10 and S=200 C=20
    : FOR    ${index}    IN RANGE    1    ${class_map_num}+1
    \    ${match_multi_vlan}    evaluate    ${match_vlan_base}+${index}
    \    create_raw_traffic_udp    tg1    match_vlan_${index}_us    service_p1    subscriber_p1    ${match_multi_vlan}
    \    ...    mac_dst=${tg_server.mac}    mac_src=00:00:00:11:11:${index}    ip_dst=${tg_server.ip}    ip_src=10.1.67.${index}    rate_mbps=${pkt_rate}

    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    stop_capture    tg1    service_p1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

    ${save_file_service_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_service_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    sleep    10s    Wait for save captured packets to ${save_file_service_p1} and

    : FOR    ${index}    IN RANGE    1    ${class_map_num}+1
    \    ${match_multi_vlan}    evaluate    ${match_vlan_base}+${index}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    (vlan.id==${service_vlan_${index}}) && (vlan.id==${match_multi_vlan}) && (eth.src==00:00:00:11:11:${index}) && (eth.dst==${tg_server.mac}) && (ip.src == 10.1.67.${index}) && (ip.dst == ${tg_server.ip})



*** Keywords ***
case setup
    [Documentation]    setup
    log    STEP:1 create class-map1 to match vlan 10 and class-map2 to match vlan 20
    log    STEP:2 create policy-map1 to bind class-map1 and policy-map2 to bind class-map2
    log    STEP:3 add eth-port1 to s-tag1=100 and s-tag2=200 with transport-service-profile(done in suite_setup)
    log    STEP:4 apply the s-tag1 and policy-map1 to the uni port； apply the s-tag2 and policy-map2 to the uni port；
    : FOR    ${index}    IN RANGE    1    ${class_map_num}+1
    \    ${match_multi_vlan}    evaluate    ${match_vlan_base}+${index}
     \    subscriber_point_add_svc    subscriber_point1      ${match_multi_vlan}     ${service_vlan_${index}}    cfg_prefix=auto_${index}


case teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    log    delete policy-map
    log    delete class-map
    : FOR    ${index}    IN RANGE    1    ${class_map_num}+1
    \    ${match_multi_vlan}    evaluate    ${match_vlan_base}+${index}
    \    subscriber_point_remove_svc    subscriber_point1      ${match_multi_vlan}     ${service_vlan_${index}}    cfg_prefix=auto_${index}
