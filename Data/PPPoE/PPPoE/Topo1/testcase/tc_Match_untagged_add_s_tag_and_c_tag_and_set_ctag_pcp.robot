*** Settings ***
Documentation     Match untagged, add s-tag and c-tag and set ctag pcp 
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_Match_untagged_add_s_tag_and_c_tag_and_set_ctag_pcp
    [Documentation]  Match untagged, add s-tag and c-tag and set ctag pcp
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2355    @globalid=2356917    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    create PPPoE server and client on STC
    # wait the engine to start
    sleep    10
    TG Create Pppoe v4 Server On Port   tg1    ${server_name}    service_p1    encap=ethernet_ii_qinq    vlan_id=${cvlan}    vlan_user_priority=0
    ...    vlan_id_outer=${p_data_vlan}    vlan_outer_user_priority=0    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1    encap=ethernet_ii    vlan_user_priority=0
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
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    0.02
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}


*** Keywords ***
case setup
    [Documentation]  setup
    log    id-profile provision
    prov_id_profile    eutA    ${id_prf1}
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan}    ctag_action=add-cevlan-tag    cvlan=${cvlan}    set-cevlan-pcp=${ctag_pcp}

case teardown
    [Documentation]  teardown
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan}    ${cvlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan}
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    id-profile    ${id_prf1}
