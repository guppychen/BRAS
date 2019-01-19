*** Settings ***
Documentation     combination of the 3 actions. The 3 services use different s-tag:
...               1. match rules: untagged: src-mac any, src-mac-mask any,ethertype any;
...               action: add2tags+set p-bit(use-p-bit + use-inner-p-bit)
...               2. match rules: tagged: match vlan + p-bit
...               action: add-tag + p-bit copy
...               3. match rules: tagged: match vlan + p-bit
...               action: add-and-change+set p-bit(use-p-bit)
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_svc_tag_action_combination_test_11
    [Documentation]    combination of the 3 actions. The 3 services use different s-tag:
    ...    1. match rules: untagged: src-mac any, src-mac-mask any,ethertype any;
    ...    action: add2tags+set p-bit(use-p-bit + use-inner-p-bit)
    ...    2. match rules: tagged: match vlan + p-bit
    ...    action: add-tag + p-bit copy
    ...    3. match rules: tagged: match vlan + p-bit
    ...    action: add-and-change+set p-bit(use-p-bit)
    [Tags]    @author=Wanlin Sun    @tcid=AXOS_E72_PARENT-TC-1224    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation    @globalid=2318877    @eut=NGPON2-4
    ...    @priority=P1
    [Setup]    AXOS_E72_PARENT-TC-1224 setup
    log    STEP:combination of the 3 actions. The 3 services use different s-tag:
    log    STEP:1. match rules: untagged: src-mac any, src-mac-mask any,ethertype any;
    log    STEP:action: add2tags+set p-bit(use-p-bit + use-inner-p-bit)
    &{result1}    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan1}    add-cevlan-tag    ${p_data_cvlan1}
    ...    set-stag-pcp=${stag_pcp}    set-cevlan-pcp=${ctag_pcp}    cfg_prefix=v1
    prov_class_map    eutA    &{result1}[classmap]    ethernet    flow    1    1    untagged=${EMPTY}
    log    STEP:2. match rules: tagged: match vlan + p-bit
    log    STEP:action: add-tag + p-bit copy
    &{result2}    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan2}    set-stag-pcp=promote    cfg_prefix=v2
    prov_class_map    eutA    &{result2}[classmap]    ethernet    flow    1    1    vlan=${p_match_vlan1}    pcp=${cetag_pcp}
    log    STEP:3. match rules: tagged: match vlan + p-bit
    log    STEP:action: add-and-change+set p-bit(use-p-bit)
    &{result3}    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan2}    ${p_data_vlan3}    cfg_prefix=v3    cevlan_action=translate-cevlan-tag
    ...    cevlan=${p_ce_add_vlan1}    set-stag-pcp=${stag_pcp}
    prov_class_map    eutA    &{result3}[classmap]    ethernet    flow    1    1    vlan=${p_match_vlan2}    pcp=${cetag_pcp}
    ${port_list}    create list    service_p1    subscriber_p1
    log    create bidirectional traffic


    Tg Create Single Tagged Stream On Port    tg1    us_match_mac    service_p1    subscriber_p1    ${subscriber_native_vlan1}    0
    ...    ${subscriber_mac1}    ${service_mac}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type_ipv6}
    ...    l3_protocol=ipv6    ipv6_dst_addr=${service_ip_v6}    ipv6_src_addr=${subscriber_ip_v6}
    Tg Create Single Tagged Stream On Port    tg1    us_match_oui    service_p1    subscriber_p1    ${subscriber_native_vlan1}    0
    ...    ${subscriber_mac2}    ${service_mac}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type_ipv6}
    ...    l3_protocol=ipv6    ipv6_dst_addr=${service_ip_v6}    ipv6_src_addr=${subscriber_ip_v6}
    Tg Create Single Tagged Stream On Port    tg1    us_match_etype    service_p1    subscriber_p1    ${subscriber_native_vlan1}    0
    ...    ${subscriber_mac3}    ${service_mac}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type}
    ...    l3_protocol=ipv4    ip_dst_addr=${service_ip}    ip_src_addr=${subscriber_ip}

    Tg Create Double Tagged Stream On Port    tg1    ds_match_mac    subscriber_p1    service_p1    ${p_data_cvlan1}    0    ${p_data_vlan1}    0
    ...    ${service_mac}    ${subscriber_mac1}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type_ipv6}
    ...    l3_protocol=ipv6    ipv6_dst_addr=${subscriber_ip_v6}    ipv6_src_addr=${service_ip_v6}
    Tg Create Double Tagged Stream On Port    tg1    ds_match_oui    subscriber_p1    service_p1    ${p_data_cvlan1}    0    ${p_data_vlan1}    0
    ...    ${service_mac}    ${subscriber_mac2}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type_ipv6}
    ...    l3_protocol=ipv6    ipv6_dst_addr=${subscriber_ip_v6}    ipv6_src_addr=${service_ip_v6}
    Tg Create Double Tagged Stream On Port    tg1    ds_match_etype    subscriber_p1    service_p1    ${p_data_cvlan1}    0    ${p_data_vlan1}    0
    ...    ${service_mac}    ${subscriber_mac3}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type}
    ...    l3_protocol=ipv4    ip_dst_addr=${subscriber_ip}    ip_src_addr=${service_ip}


    Tg Create Single Tagged Stream On Port    tg1     us_match2    service_p1    subscriber_p1    ${p_match_vlan1}    ${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_src=${subscriber_mac4}    mac_dst=${service_mac2}    rate_pps=${rate_pps1}
    ...    l3_protocol=ipv4    ip_dst_addr=${service_ip}    ip_src_addr=${subscriber_ip}
    Tg Create Double Tagged Stream On Port    tg1    ds_match2    subscriber_p1    service_p1    ${p_match_vlan1}    0    ${p_data_vlan2}    0
    ...    ${service_mac2}    ${subscriber_mac4}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type}
    ...    l3_protocol=ipv4    ip_dst_addr=${subscriber_ip}    ip_src_addr=${service_ip}


    Tg Create Single Tagged Stream On Port    tg1     us_match3    service_p1    subscriber_p1    ${p_match_vlan2}    ${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_src=${subscriber_mac5}    mac_dst=${service_mac3}    rate_pps=${rate_pps1}
    ...    l3_protocol=ipv4    ip_dst_addr=${service_ip}    ip_src_addr=${subscriber_ip}
    Tg Create Double Tagged Stream On Port    tg1    ds_match3    subscriber_p1    service_p1    ${p_ce_add_vlan1}    0    ${p_data_vlan3}    0
    ...    ${service_mac3}    ${subscriber_mac5}    frame_size=512    length_mode=fixed    rate_pps=${rate_pps1}    ether_type=${ether_type}
    ...    l3_protocol=ipv4    ip_dst_addr=${subscriber_ip}    ip_src_addr=${service_ip}


    log    run traffic
    Tg Start All Traffic    tg1
    Tg Packet Control    tg1    ${port_list}    start
    log    sleep for capturing enough packets
    sleep    ${run_traffic_time}
    Tg Packet Control    tg1    ${port_list}    stop
    Tg Stop All Traffic    tg1
    log    sleep for stop working
    sleep    ${wait_stop_time}

    log    verify no traffic loss
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match_mac    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match_oui    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match_etype    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match_mac    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match_oui    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match_etype    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match2    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    us_match3    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match2    0.1
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_match3    0.1
    ${p1_cap}    generate_pcap_name    combination_test_11
    Tg Store Captured Packets    tg1    service_p1    ${p1_cap}
    log    verify first streams packets
    wsk Load File    ${p1_cap}    vlan.id == ${p_data_vlan1}
    Wsk Verify Pbit By Index    ${stag_pcp}    1
    Wsk Verify Pbit By Index    ${ctag_pcp}    2
    Wsk Verify Vlan By Index    ${p_data_vlan1}    1
    Wsk Verify Vlan By Index    ${p_data_cvlan1}    2
    log    verify second streams packets
    wsk Load File    ${p1_cap}    vlan.id == ${p_data_vlan2}
    Wsk Verify Pbit By Index    ${cetag_pcp}    1
    Wsk Verify Pbit By Index    ${cetag_pcp}    2
    Wsk Verify Vlan By Index    ${p_data_vlan2}    1
    Wsk Verify Vlan By Index    ${p_match_vlan1}    2
    log    verify third streams packets
    wsk Load File    ${p1_cap}    vlan.id == ${p_data_vlan3}
    Wsk Verify Pbit By Index    ${stag_pcp}    1
    Wsk Verify Pbit By Index    ${cetag_pcp}    2
    Wsk Verify Vlan By Index    ${p_data_vlan3}    1
    Wsk Verify Vlan By Index    ${p_ce_add_vlan1}    2
    Tg Clear Traffic Stats    tg1
    [Teardown]    AXOS_E72_PARENT-TC-1224 teardown

*** Keywords ***
AXOS_E72_PARENT-TC-1224 setup
    log    Enter AXOS_E72_PARENT-TC-1224 setup
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}
    prov_vlan    eutA    ${p_data_vlan3}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1},${p_data_vlan2},${p_data_vlan3}


AXOS_E72_PARENT-TC-1224 teardown
    log    Enter AXOS_E72_PARENT-TC-1224 teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan1}    ${p_data_cvlan1}    cfg_prefix=v1
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan2}    cfg_prefix=v2
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan2}    ${p_data_vlan3}    cevlan=${p_ce_add_vlan1}    cfg_prefix=v3
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1},${p_data_vlan2},${p_data_vlan3}

    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    vlan    ${p_data_vlan3}
