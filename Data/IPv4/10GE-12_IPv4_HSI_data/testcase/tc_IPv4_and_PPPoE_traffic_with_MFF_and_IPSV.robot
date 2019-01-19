*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=IPv4      @author=Anson Zhang

*** Variables ***


*** Test Cases ***
tc_IPv4_and_PPPoE_traffic_with_MFF_and_IPSV
    [Documentation]

    ...    1	Add data service with DHCP and PPPoE in the same VLAN with MFF and IPSV	success
    ...    2	create DHCP and PPPoE sessions	success
    ...    3	Send bi-directional UDP/TCP traffic for DHCP and PPPoE	no packet loss
    ...    4	switchover	no packet loss


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4713      @subFeature=IPv4 HSI data      @globalid=2533445      @priority=P1      @eut=10GE-12          @user_interface=CLI
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:1 Add data service with DHCP and PPPoE in the same VLAN with MFF and IPSV success

    log    STEP:2 create DHCP and PPPoE sessions success
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${p_lease_negociate_time}
    log    check the dhcp lease
    check_l3_hosts    eutA    vlan=${p_service_vlan_1}    interface=${service_model.subscriber_point1.name}

    log    create pppoe session
    Tg Control Pppox By Name    tg1    pppoeserver    connect
    Tg Control Pppox By Name    tg1    pppoeclient    connect
    Tg Wait Until All Pppox Session Negotiated    tg1    subscriber_p1    ${p_pppoe_negotiated_time}

    log    STEP:3 Send bi-directional UDP/TCP traffic for DHCP and PPPoE no packet loss
    create_bound_traffic_udp    tg1    dhcp_us    subscriber_p1    dserver    dcg    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    dhcp_ds    service_p1    dcg    dserver    ${p_rate_mbps}

    log    create pppoe traffic
    create_bound_traffic_udp    tg1    pppoe_us    subscriber_p1    pppoeserver    pppoeclient    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    pppoe_ds    service_p1    pppoeclient    pppoeserver    ${p_rate_mbps}

    log    learn the mac address
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


*** Keywords ***
case setup
    [Documentation]
    log    id-profile provision
    prov_id_profile    eutA    ${p_pppoe_profile}
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${p_dhcp_profile_name}    id-name ${p_pppoe_profile}
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan_1}    ${p_dhcp_profile_name}    source-verify=enabled    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_service_vlan_1}
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_service_vlan_1}

    log    create dhcp server and client
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ${p_service_vlan_1}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${p_dhcp_client.mac}

    log    create pppoe server and client
    TG Create Pppoe v4 Server On Port    tg1    pppoeserver    service_p1    encap=ethernet_ii_vlan    vlan_id=${p_service_vlan_1}    vlan_user_priority=0
    ...    vlan_id_count=1    num_sessions=1    mac_addr=${p_pppoe_server.mac}
    TG Create PPPoE v4 Client On Port    tg1    pppoeclient    subscriber_p1    encap=ethernet_ii    num_sessions=1    mac_addr=${p_pppoe_client.mac}

case teardown
    [Documentation]
    log    delete the dhcp server and client
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver

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
    delete_config_object    eutA    l2-dhcp-profile    ${p_dhcp_profile_name}
    log    delete the pppoe profile
    delete_config_object    eutA    id-profile    ${p_pppoe_profile}