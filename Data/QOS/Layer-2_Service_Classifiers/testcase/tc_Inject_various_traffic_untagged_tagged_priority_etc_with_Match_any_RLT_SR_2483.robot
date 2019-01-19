*** Settings ***
Documentation     This test case is to confirm various traffic works with match rule match any.
...    Following traffic type will be tested.
...    * untagged, priority tagged, VLAN tagged, various Ethertype, Source MAC address, OUI, etc.
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu

*** Variables ***

*** Test Cases ***
tc_Inject_various_traffic_untagged_tagged_priority_etc_with_Match_any_RLT_SR_2483
    [Documentation]
    ...    #	Action	Expected Result	Notes
    ...    1	Provision match rule match any, confirm provision complete.
    ...    2	Inject various type of traffic, example in the description, confirm all traffic passes through with match any rule.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-947    @globalid=2316404    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-947 setup
    [Teardown]   AXOS_E72_PARENT-TC-947 teardown
    log    STEP:

    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision match rule match any, confirm provision complete.

    log    STEP:2 Inject various type of traffic, example in the description, confirm all traffic passes through with match any rule.


    log    STEP:1. match rules: any;
    log    serivce 1
    log    STEP:action: add-tag + set pbit vlan ${p_data_vlan1}
    &{result1}    subscriber_point_add_svc    subscriber_point1    any    ${p_data_vlan1}    set-stag-pcp=${stag_pcp}    cfg_prefix=match_any
    prov_class_map     eutA    &{result1}[classmap]    ethernet    flow    1    1    any=${EMPTY}

    log    run traffic
    ${port_list}    create list    service_p1    subscriber_p1
    log    create upstream traffic

    log    traffic with udp
    log    untag traffic
    create_raw_traffic_udp    tg1    up_untag    service_p1    subscriber_p1
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}


    log    tag traffic
    create_raw_traffic_udp    tg1    up_tag    service_p1    subscriber_p1    ovlan=${p_data_cvlan1}
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}


    log    priority traffic
    create_raw_traffic_udp    tg1    up_pri    service_p1    subscriber_p1    ovlan=${p_match_remove}    ivlan=${p_data_cvlan2}
    ...    frame_size=512    length_mode=fixed    mac_dst=${service_mac}    mac_src=${subscriber_mac1}    ip_dst=${sip}    ip_src=${cip}
    ...    rate_mbps=${rate_pps1}

    log    create downstream traffic
    log     traffic with udp

    log    traffic with vlan ${p_data_vlan1}
    create_raw_traffic_udp    tg1    down1    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}

    log    traffic with vlan ${p_data_vlan2}
    create_raw_traffic_udp    tg1    down2    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}

    log    traffic with vlan ${p_data_vlan3}
    create_raw_traffic_udp    tg1    down3    subscriber_p1    service_p1    ovlan=${p_data_vlan1}    ovlan_pbit=${cetag_pcp}
    ...    frame_size=512    length_mode=fixed    mac_dst=${subscriber_mac1}    mac_src=${service_mac}    ip_dst=${cip}    ip_src=${sip}
    ...    rate_mbps=${rate_pps1}

    log    run traffic

    log    learn arp
    Tg Start All Traffic    tg1
    sleep    ${learn_arp_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1

    log    run traffic and start stats
    Tg Start All Traffic     tg1
    Tg Packet Control    tg1    ${port_list}    start
    log    sleep for capturing enough packets
    sleep    ${run_traffic_time}
    Tg Packet Control    tg1    ${port_list}    stop
    Tg Stop All Traffic    tg1
    log    sleep for stop working
    sleep    ${wait_stop_time}
    Tg Save Config Into File    tg1     /tmp/stream.xml

    log    verify no traffic loss


    Tg Verify Traffic Loss For Stream Is Within    tg1    up_untag    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    up_tag    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    up_pri    ${loss_rate}


    ${p1_cap}    generate_pcap_name    combination_test_1
    Tg Store Captured Packets    tg1    service_p1    ${p1_cap}

    log    verify first streams packets
    wsk Load File    ${p1_cap}    vlan.id==${p_data_vlan1}
    Wsk Verify Outer Pbit    ${stag_pcp}





*** Keyword ***
AXOS_E72_PARENT-TC-947 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}
    prov_vlan    eutA    ${p_data_vlan3}

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


AXOS_E72_PARENT-TC-947 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1

    subscriber_point_remove_svc    subscriber_point1    any    ${p_data_vlan1}    cfg_prefix=match_any

    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    vlan    ${p_data_vlan3}
