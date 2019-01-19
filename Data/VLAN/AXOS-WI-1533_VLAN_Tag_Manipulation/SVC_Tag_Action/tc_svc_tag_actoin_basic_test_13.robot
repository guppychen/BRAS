
*** Settings ***
Documentation     match rule:
...    tagged: only match vlan, p-bit any
...    Action:
...    add-tag and set p-bit
Resource          ./base.robot


*** Variables ***




*** Test Cases ***
tc_svc_tag_actoin_basic_test_13
    [Documentation]    match rule:
    ...    tagged: only match vlan, p-bit any
    ...    Action:
    ...    add-tag and set p-bit
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1198    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318851    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1198 setup
    [Teardown]   AXOS_E72_PARENT-TC-1198 teardown
    log    STEP:Action:add-tag and set p-bit
    &{result}    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan1}    set-stag-pcp=${stag_pcp}
    log    STEP:match rule:tagged: only match vlan, p-bit any
    prov_class_map     eutA    &{result}[classmap]    ethernet    flow    1    1    vlan=${p_match_vlan1}
    ${port_list}    create list    service_p1    subscriber_p1

    log    create bidirectional traffic
    Tg Create Single Tagged Stream On Port    tg1     us_match_vlan    service_p1    subscriber_p1    ${p_match_vlan1}    ${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_src=${subscriber_mac1}    mac_dst=${service_mac}    rate_pps=${rate_pps1}
    ...    l3_protocol=ipv4    ip_dst_addr=${service_ip}    ip_src_addr=${subscriber_ip}
    Tg Create Double Tagged Stream On Port    tg1    ds_match_vlan    subscriber_p1    service_p1    ${p_match_vlan1}    0    ${p_data_vlan1}    0
    ...    ${service_mac}    ${subscriber_mac1}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type}
    ...    l3_protocol=ipv4    ip_dst_addr=${subscriber_ip}    ip_src_addr=${service_ip}


    log    run traffic
    Tg Start All Traffic     tg1
    Tg Packet Control    tg1    ${port_list}    start
    log    sleep for capturing enough packets
    sleep    ${run_traffic_time}
    Tg Packet Control    tg1    ${port_list}    stop
    Tg Stop All Traffic    tg1
    log    sleep for stop working
    sleep    ${wait_stop_time}

    log    verify no traffic loss
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match_vlan    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match_vlan    0.1

    ${p1_cap}    generate_pcap_name    basic_test_13
    Tg Store Captured Packets    tg1    service_p1    ${p1_cap}
    wsk Load File    ${p1_cap}    eth.dst == ${service_mac}
    Wsk Verify Pbit By Index    ${stag_pcp}    1
    Wsk Verify Pbit By Index    ${cetag_pcp}    2
    Wsk Verify Vlan By Index    ${p_data_vlan1}  1
    Wsk Verify Vlan By Index    ${p_match_vlan1}  2
    Tg Clear Traffic Stats    tg1


*** Keywords ***
AXOS_E72_PARENT-TC-1198 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1198 setup
    log    create vlan
    prov_vlan    eutA    ${p_data_vlan1}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}


AXOS_E72_PARENT-TC-1198 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1198 teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    subscriber_point remove_svc
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan1}
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}

