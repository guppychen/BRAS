*** Settings ***
Documentation     The untagged traffic can pass form Access interface to uplink interface.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DSCP_map_working_with_match_rule_untagged
    [Documentation]    The untagged traffic can pass form Access interface to uplink interface.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1249    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318911    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1249 setup
    [Teardown]   AXOS_E72_PARENT-TC-1249 teardown
    log    STEP:The untagged traffic can pass form Access interface to uplink interface.
    ${port_list}    create list    service_p1    subscriber_p1

    Tg Create Single Tagged Stream On Port    tg1    upstream    service_p1    subscriber_p1    ${subscriber_native_vlan1}    0
    ...    mac_src=${subscriber_mac1}    mac_dst=${service_mac}    rate_pps=${rate_pps1}    l3_protocol=ipv4    ip_dscp=${dscp_value1}
    ...    ip_dst_addr=${service_ip}    ip_src_addr=${subscriber_ip}    frame_size=512    length_mode=fixed

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
    Tg Verify Traffic Loss For Stream Is Within    tg1    upstream    0.1
    ${p1_cap}    generate_pcap_name    match_rule_untagged
    Tg Store Captured Packets    tg1    service_p1    ${p1_cap}
    wsk Load File    ${p1_cap}    eth.dst == ${service_mac}
    Wsk Verify Pbit By Index    ${p_value1}    1
    Wsk Verify Vlan By Index    ${p_data_vlan1}  1
    Tg Clear Traffic Stats    tg1


*** Keywords ***
AXOS_E72_PARENT-TC-1249 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1249 setup

    log    create vlan
    prov_vlan    eutA    ${p_data_vlan1}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}

    prov_dscp_map    eutA    ${dscp_map1}    ${dscp_value1}     ${p_value1}
    ${type}    set variable    ${service_model.subscriber_point1.type}
    ${port_type1}    set variable if    'ont_port'=='${type}'    ont-ethernet
    set test variable    ${port_type}    ${port_type1}

    log    Apply DSCP map to Access interface.
    prov_interface     eutA    ${port_type}    ${service_model.subscriber_point1.name}     role=uni    dscp-map=${dscp_map1}
    &{result}    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan1}
    prov_class_map    eutA    &{result}[classmap]    ethernet    flow    1    1    untagged=${EMPTY}


AXOS_E72_PARENT-TC-1249 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1249 teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    log    subscriber_point remove_svc
    dprov_interface    eutA    ${port_type}     ${service_model.subscriber_point1.name}    dscp-map=${EMPTY}
    dprov_dscp_map    eutA    ${dscp_map1}
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan1}
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}

