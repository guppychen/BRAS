*** Settings ***
Force Tags        @feature=IPv4    @author=Anson Zhang
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_PPPoE_traffic
    [Documentation]    1 Add PPPoE service success
    ...    2 create PPPoE session success
    ...    3 Send bi-directional UDP/TCP traffic no packet loss
    ...    4 switchover no packet loss
    [Tags]    @tcid=AXOS_E72_PARENT-TC-4714    @subFeature=IPv4 HSI data    @globalid=2533446    @priority=P1    @eut=10GE-12    @user_interface=CLI
    [Setup]    case setup
    log    STEP:1 Add PPPoE service success
    log    STEP:2 create PPPoE session success
    Tg Control Pppox By Name    tg1    pppoeserver    connect
    Tg Control Pppox By Name    tg1    pppoeclient    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${p_pppoe_negotiated_time}
    log    create traffic
    create_bound_traffic_udp    tg1    pppoe_us    subscriber_p1    pppoeserver    pppoeclient    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    pppoe_ds    service_p1    pppoeclient    pppoeserver    ${p_rate_mbps}
    log    STEP:3 Send bi-directional UDP/TCP traffic no packet loss
    log    learn the mac
    Tg Start All Traffic    tg1
    sleep    ${p_traffic_time_to_learn_mac}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    log    start the traffic to verify the performance
    Tg Start All Traffic    tg1
    log    STEP:4 switchover no packet loss
    redundancy_switchover    eutA    switchover    retry_time=${p_switchover_retry}
    Wait Until Keyword Succeeds    ${p_check_switchover_status}    10s    check_switchover_status    eutA    switchover-dm-in-sync-status="All DMs in sync"
    log    stop and check traffic
    Tg Stop All Traffic    tg1
    log    wait for stc traffic stop
    sleep    ${p_stc_traffic_stop}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    id-profile provision
    prov_id_profile    eutA    ${p_pppoe_profile}
    log    create a vlan
    prov_vlan    eutA    ${p_service_vlan_1}    pppoe-ia-id-profile=${p_pppoe_profile}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_service_vlan_1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_service_vlan_1}
    log    create pppoe server and client
    TG Create Pppoe v4 Server On Port    tg1    pppoeserver    service_p1    encap=ethernet_ii_vlan    vlan_id=${p_service_vlan_1}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${p_pppoe_server.mac}
    TG Create PPPoE v4 Client On Port    tg1    pppoeclient    subscriber_p1    encap=ethernet_ii    num_sessions=1    mac_addr=${p_pppoe_client.mac}
    log    save the stc file
    Tg Save Config Into File    tg1    /tmp/pppoe.xml
case teardown
    log    delete stc device and traffic
    Tg Control Pppox By Name    tg1    pppoeserver    disconnect
    Tg Control Pppox By Name    tg1    pppoeclient    disconnect
    Tg Delete All Traffic    tg1
    TG Delete PPPoE v4 Client On Port    tg1    pppoeclient    subscriber_p1
    TG Delete PPPoE v4 Server On Port    tg1    pppoeserver    service_p1
    log    remvoe service from uni port
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_service_vlan_1}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_service_vlan_1}
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan_1}
    delete_config_object    eutA    id-profile    ${p_pppoe_profile}
