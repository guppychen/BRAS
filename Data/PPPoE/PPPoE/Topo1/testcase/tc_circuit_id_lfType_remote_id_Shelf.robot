*** Settings ***
Documentation     circuit-id=%IfType ; remote-id=%Shelf
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***

*** Test Cases ***
tc_circuit_id_lfType_remote_id_Shelf
    [Documentation]    circuit-id=%IfType ; remote-id=%Shelf
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2506    @globalid=2360102    @eut=NGPON2-4    @priority=P1
    [Setup]      setup
    [Teardown]   teardown
    log    create PPPoE server and client on STC
    # wait the engine to start
    sleep    10
    TG Create Pppoe v4 Server On Port   tg1    ${server_name}    service_p1    encap=ethernet_ii_vlan    vlan_id=${p_data_vlan}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
    TG Create PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1    encap=ethernet_ii    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${client_mac}
    start_capture    tg1    subscriber_p1
    start_capture    tg1    service_p1
    Tg Control Pppox By Name    tg1    ${server_name}    connect
    Tg Control Pppox By Name    tg1    ${client_name}    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${pppoe_negotiated_time}

    log    check the PPPoE Tag from the PADI packet
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    check_circuit_id    tg1    service_p1    ont
    check_remote_id    tg1    service_p1    1

*** Keywords ***
setup
    [Documentation]  setup
    log    id-profile provision
    prov_id_profile    eutA    ${id_prf1}    circuit-id=%IfType    remote-id=%Shelf
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan}

teardown
    [Documentation]  teardown
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan}
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    id-profile    ${id_prf1}

