*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=VLAN      @author=Anson Zhang

*** Variables ***


*** Test Cases ***
tc_multi_services_with_remove_cevlan
    [Documentation]

    ...    1	create a class-map 1 to match VLAN 10 in flow 1	successfully
    ...    2	create a policy-map 1 to bind the class-map 1 and remove-cevlan	successfully
    ...    3	create a class-map 2 to match VLAN 11 in flow 1	successfully
    ...    4	create a policy-map 2 to bind the class-map 2 and remove-cevlan	successfully
    ...    5	add eth-port1 to s-tag x and y with transport-service-profile	successfully
    ...    6	apply the s-tag x and policy-map 1 to the uni ethernet port	successfully
    ...    7	apply the s-tag y and policy-map 2 to the uni ethernet port	successfully
    ...    8	send VLAN 10 and 11 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002;	eth-port1 can pass the upstream traffic with right s-tag
    ...    9	send single-tagged x and y downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001;	client can receive the downstream traffic with right cevlan.


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4383    @subFeature=VLAN mapping: change C-Tag to an S-Tag    @globalid=2532639    @priority=P1    @eut=10GE-12    @user_interface=CLI    @PASS=true
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:1 create a class-map 1 to match VLAN 10 in flow 1 successfully

    log    STEP:2 create a policy-map 1 to bind the class-map 1 and remove-cevlan successfully

    log    STEP:3 create a class-map 2 to match VLAN 11 in flow 1 successfully

    log    STEP:4 create a policy-map 2 to bind the class-map 2 and remove-cevlan successfully

    log    STEP:5 add eth-port1 to s-tag x and y with transport-service-profile successfully

    log    STEP:6 apply the s-tag x and policy-map 1 to the uni ethernet port successfully

    log    STEP:7 apply the s-tag y and policy-map 2 to the uni ethernet port successfully

    log    STEP:8 send VLAN 10 and 11 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002; eth-port1 can pass the upstream traffic with right s-tag

    log    STEP:9 send single-tagged x and y downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001; client can receive the downstream traffic with right cevlan.
    log    start the dhcp server and client
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Control Dhcp Server    tg1    dserver_2    start
    Tg Control Dhcp Client    tg1    dcg_2    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${p_lease_negociate_time}

    log    create bound traffic
    create_bound_traffic_udp    tg1    dhcp_us    subscriber_p1    dserver    dcg    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    dhcp_ds    service_p1    dcg    dserver    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    dhcp_us_2    subscriber_p1    dserver_2    dcg_2    ${p_rate_mbps}
    create_bound_traffic_udp    tg1    dhcp_ds_2    service_p1    dcg_2    dserver_2    ${p_rate_mbps}
    log    learn the mac
    Tg Start All Traffic    tg1
    sleep    ${p_traffic_time_to_learn_mac}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    log    start the traffic to verify the performance
    Tg Start All Traffic    tg1
    sleep    ${p_traffic_run_time}
    log    stop and check traffic
    Tg Stop All Traffic    tg1
    log    wait for stc traffic stop
    sleep    ${p_stc_traffic_stop}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${p_traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]
    log    provision the first service
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan}
    prov_vlan_egress    eutA    ${p_service_vlan}    broadcast-flooding    ENABLED
    prov_vlan    eutA    ${p_service_vlan_2}
    prov_vlan_egress    eutA    ${p_service_vlan_2}    broadcast-flooding    ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_service_vlan},${p_service_vlan_2}
    log    service add
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=remove-cevlan    cfg_prefix=auto${p_service_vlan}
    log    create dhcp server and client
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ovlan=${p_service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${p_dhcp_client.mac}    ovlan=${p_match_vlan}

    log    provision the second service
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan_2}    ${p_service_vlan_2}    cevlan_action=remove-cevlan    cfg_prefix=auto${p_service_vlan_2}
    log    create dhcp server and client
    create_dhcp_server    tg1    dserver_2    service_p1    ${p_dhcp_server_2.mac}    ${p_dhcp_server_2.ip}    ${p_dhcp_server_2.startup_ip}
    ...    ovlan=${p_service_vlan_2}
    create_dhcp_client    tg1    dclient_2    subscriber_p1    dcg_2    ${p_dhcp_client_2.mac}    ovlan=${p_match_vlan_2}

case teardown
    [Documentation]
    log    delete the tg server and client
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    Tg Delete Dhcp Client    tg1    dclient_2
    Tg Delete Dhcp Server    tg1    dserver_2
    log    remvoe service from uni port
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cfg_prefix=auto${p_service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan_2}    ${p_service_vlan_2}    cfg_prefix=auto${p_service_vlan_2}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_service_vlan},${p_service_vlan_2}
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan}
    delete_config_object    eutA    vlan    ${p_service_vlan_2}