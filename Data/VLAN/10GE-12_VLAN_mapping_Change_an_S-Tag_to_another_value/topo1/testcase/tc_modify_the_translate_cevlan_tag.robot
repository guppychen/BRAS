*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=VLAN      @author=Anson Zhang

*** Variables ***
${new_trans_cevlan}    3030

*** Test Cases ***
tc_modify_the_translate_cevlan_tag
    [Documentation]

    ...    1	create a class-map to match VLAN 10 in flow 1	successfully
    ...    2	create a policy-map to bind the class-map and translate-cevlan-tag 20	successfully
    ...    3	add eth-port1 to s-tag with transport-service-profile	successfully
    ...    4	apply the s-tag and policy-map to the uni ethernet port	successfully
    ...    5	send VLAN 10 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002;	eth-port1 can pass the upstream traffic with cevlan 20
    ...    6	send double-tagged downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001;	client can receive the downstream traffic with vlan 10
    ...    7	modify the policy map with translate-cevlan-tag 30 instead of VLAN 20	successfully
    ...    8	repeat steps 5 to 6	the traffic can work with right s-tag and c-tag


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4399      @subFeature=VLAN mapping: Change an S-Tag to another value      @globalid=2532661      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12          @user_interface=CLI
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:1 create a class-map to match VLAN 10 in flow 1 successfully

    log    STEP:2 create a policy-map to bind the class-map and translate-cevlan-tag 20 successfully

    log    STEP:3 add eth-port1 to s-tag with transport-service-profile successfully

    log    STEP:4 apply the s-tag and policy-map to the uni ethernet port successfully

    log    STEP:5 send VLAN 10 upstream traffic to uni ethernet port with SMAC 000001000001 DMAC 000002000002; eth-port1 can pass the upstream traffic with cevlan 20

    log    STEP:6 send double-tagged downstream traffic to eth-port1 with SMAC 000002000002 DMAC 000001000001; client can receive the downstream traffic with vlan 10
    run_dhcp_and_check_traffic    dserver    dcg    service_p1    subscriber_p1    traffic_loss_rate=${p_traffic_loss_rate}
    log    STEP:7 modify the policy map with translate-cevlan-tag 30 instead of VLAN 20 successfully
    dprov_policy_map    eutA    &{dict_prov_service}[policymap]    class-map-ethernet    &{dict_prov_service}[classmap]    flow    1
    ...    translate-cevlan-tag=${EMPTY}
    prov_policy_map    eutA    &{dict_prov_service}[policymap]    class-map-ethernet    &{dict_prov_service}[classmap]    flow    1
    ...    translate-cevlan-tag=${new_trans_cevlan}
    log    STEP:8 repeat steps 5 to 6 the traffic can work with right s-tag and c-tag
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Server    tg1    dserver
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ovlan=${p_service_vlan}    ivlan=${new_trans_cevlan}
    log    verify the new service
    run_dhcp_and_check_traffic    dserver    dcg    service_p1    subscriber_p1    traffic_loss_rate=${p_traffic_loss_rate}

*** Keywords ***
case setup
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan}
    prov_vlan_egress    eutA    ${p_service_vlan}    broadcast-flooding    ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_service_vlan}
    &{dict_prov_service}    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${p_translate_vlan}
    Set Suite Variable    &{dict_prov_service}
    log    create dhcp server and client
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ovlan=${p_service_vlan}    ivlan=${p_translate_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${p_dhcp_client.mac}    ovlan=${p_match_vlan}

case teardown
    log    delete the tg server and client
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    log    remvoe service from uni port
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan=${p_translate_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${p_service_vlan}
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan}