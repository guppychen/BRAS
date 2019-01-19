*** Settings ***
Documentation     Interoperate with DHCP
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***
${dserver_ip}  10.10.10.1
${dclient_ip}  10.10.10.10
${lease_negotiate_time}  30

*** Test Cases ***
tc_Interoperate_with_DHCP
    [Documentation]    Interoperate with DHCP
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2378    @globalid=2356931    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Interoperate with DHCP
    log    create DHCP server and client on STC
    # wait the engine to start
    sleep    10
    create_dhcp_server    tg1    dserver    service_p1    ${server_mac}    ${dserver_ip}    ${dclient_ip}    ${p_data_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${client_mac}
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negotiate_time}
    log    show dhcp leases
    check_l3_hosts    eutA    1    ${p_data_vlan}    ${service_model.subscriber_point1.name}
    log    create bi-directional bound traffic
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    rate_pps=1000
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    rate_pps=1000

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
    TG Verify Traffic Loss For Stream Is Within    tg1    dhcp_upstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    dhcp_downstream    ${loss_rate}
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Control Dhcp Server    tg1    dserver    stop
    TG Delete Dhcp Client    tg1    dclient
    TG Delete Dhcp Server    tg1    dserver

    log    create PPPoE server and client on STC
    TG Create Pppoe v4 Server On Port   tg1    ${server_name}    service_p1    encap=ethernet_ii_vlan    vlan_id=${p_data_vlan}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${server_mac}
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
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}


*** Keywords ***
case setup
    [Documentation]  setup
    log    id-profile,l2-dhcp-profile provision
    prov_id_profile    eutA    ${id_prf1}    circuit-id=%SystemId    remote-id=%SystemId
    prov_dhcp_profile    eutA    ${dhcp_prf}    option=id-name ${id_prf1}
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile=${dhcp_prf}    pppoe-ia-id-profile=${id_prf1}    mac-learning=enable
    prov_vlan_egress    eutA    ${p_data_vlan}    broadcast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan}

case teardown
    [Documentation]  teardown
    log    teardown
    Tg Control Pppox By Name    tg1    ${client_name}    disconnect
    Tg Control Pppox By Name    tg1    ${server_name}    disconnect
    TG Delete PPPoE v4 Client On Port    tg1    ${client_name}    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    ${server_name}    service_p1
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_data_vlan}
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_prf}
    delete_config_object    eutA    id-profile    ${id_prf1}
