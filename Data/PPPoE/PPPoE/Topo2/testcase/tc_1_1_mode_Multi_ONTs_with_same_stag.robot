*** Settings ***
Documentation     (1:1 mode)Multi ONTs with same stag
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_1_1_mode_Multi_ONTs_with_same_stag
    [Documentation]    (1:1 mode)Multi ONTs with same stag
    [Tags]    @author=joli    @tcid=AXOS_E72_PARENT-TC-2522    @globalid=2360118    @eut=NGPON2-4    @priority=P2
    [Setup]    case setup
    log    STEP:(1:1 mode)Multi ONTs with same stag
    # wait the engine to start
    sleep    10
    log    create PPPoE server and client on STC
    TG Create Pppoe v4 Server On Port    tg1    ${server_name}    service_p1    encap=ethernet_ii_qinq    vlan_id=${cvlan}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan3}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1    encap=ethernet_ii_vlan    vlan_id=${p_match_vlan}    vlan_user_priority=0    vlan_id_count=1
    ...    num_sessions=1    mac_addr=${client_mac}
    TG Create Pppoe v4 Server On Port    tg1    ${server_name2}    service_p1    encap=ethernet_ii_qinq    vlan_id=${cvlan2}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan3}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    ${client_name2}    subscriber_p2    encap=ethernet_ii_vlan    vlan_id=${p_match_vlan}    vlan_user_priority=0    vlan_id_count=1
    ...    num_sessions=1    mac_addr=${client_mac2}
    log    2 PPPoE sessions established successfully
    Tg Control Pppox By Name    tg1    ${server_name}    connect
    Tg Control Pppox By Name    tg1    ${client_name}    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}
    Tg Control Pppox By Name    tg1    ${server_name2}    connect
    Tg Control Pppox By Name    tg1    ${client_name2}    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p2    ${pppoe_negotiated_time}
#    log    delete one session
#    delete_pppoe_session    eutA    ${p_data_vlan3}    ${client_mac2}
#    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    Tg Control Pppox By Name    tg1    ${client_name2}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name2}    disconnect
    # wait the engine to stop
    sleep    10
    [Teardown]    case teardown

*** Keywords ***
case setup
    [Documentation]    setup
    log    create id-profile
    prov_id_profile    eutA    ${id_prf1}
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan3}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable    mode=ONE2ONE
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan3}
    log    l2 basic setting
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    vlan=${p_match_vlan}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    ...    remove-cevlan=${EMPTY}
    subscriber_point_add_svc_one2one    subscriber_point1    ${p_data_vlan3}    ${cvlan}    ${policy_map_name}
    subscriber_point_add_svc_one2one    subscriber_point2    ${p_data_vlan3}    ${cvlan2}    ${policy_map_name}

case teardown
    [Documentation]    teardown
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name2}    subscriber_p2
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name2}    service_p1
    subscriber_point_remove_svc_one2one    subscriber_point1    ${p_data_vlan3}    ${cvlan}    ${policy_map_name}
    subscriber_point_remove_svc_one2one    subscriber_point2    ${p_data_vlan3}    ${cvlan2}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan3}
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan3}    pppoe-ia-id-profile
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${p_data_vlan3}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
    delete_config_object    eutA    id-profile    ${id_prf1}
