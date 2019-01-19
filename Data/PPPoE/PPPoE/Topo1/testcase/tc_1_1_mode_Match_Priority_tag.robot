*** Settings ***
Documentation     (1:1 mode)Match Priority tag
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***

*** Test Cases ***
tc_1_1_mode_Match_Priority_tag
    [Documentation]    (1:1 mode)Match Priority tag 
    [Tags]    @author=joli    @globalid=2360117    @tcid=AXOS_E72_PARENT-TC-2521     @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    log    create PPPoE server and client on STC
    # wait the engine to start
    sleep    10
    TG Create Pppoe v4 Server On Port   tg1    ${server_name}    service_p1    encap=ethernet_ii_qinq    vlan_id=${cvlan}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan3}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1    encap=ethernet_ii_vlan    vlan_id=0    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${client_mac}
    Tg Control Pppox By Name    tg1    ${server_name}    connect
    Tg Control Pppox By Name    tg1    ${client_name}    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}

    log    create upstream and downstream flow
    Tg Create Bound Untagged Stream On Port    tg1    upstream    subscriber_p1    ${server_name}    ${client_name}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed
    Tg Create Bound Untagged Stream On Port    tg1    downstream    service_p1    ${client_name}    ${server_name}    frame_size=500
    ...    rate_kbps=${rate_kbps}    length_mode=fixed

    log    check all traffic can pass
    Tg Start All Traffic     tg1
    # wait time to make traffic stable
    sleep    ${sleep_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    log    id-profile provision
    prov_id_profile    eutA    ${id_prf1}
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan3}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable    mode=ONE2ONE
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan3}
    log    l2 basic setting
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}    priority-tagged=${EMPTY}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    remove-cevlan=${EMPTY}    sub_view_type=flow    sub_view_value=${flow_index}
#    prov_ont_interface    eutA    ${interface_type}    ${service_model.subscriber_point1.name}    ${p_data_vlan3}    c_vlan=${cvlan}    policy_map_name=${policy_map_name}
    subscriber_point_add_svc_one2one    subscriber_point1    ${p_data_vlan3}    ${cvlan}    ${policy_map_name}

teardown
    [Documentation]    teardown
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
#    dprov_ont_interface    eutA    ${interface_type}    ${service_model.subscriber_point1.name}    ${p_data_vlan3}    c_vlan=${cvlan}    policy_map_name=${policy_map_name}
    subscriber_point_remove_svc_one2one    subscriber_point1    ${p_data_vlan3}    ${cvlan}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan3}
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan3}    pppoe-ia-id-profile
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${p_data_vlan3}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
    delete_config_object    eutA    id-profile    ${id_prf1}

