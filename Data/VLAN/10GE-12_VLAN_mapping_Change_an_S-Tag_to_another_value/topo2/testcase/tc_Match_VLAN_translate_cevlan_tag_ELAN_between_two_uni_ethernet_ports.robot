*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=VLAN      @author=Anson Zhang

*** Variables ***


*** Test Cases ***
tc_Match_VLAN_translate_cevlan_tag_ELAN_between_two_uni_ethernet_ports
    [Documentation]

    ...    1	create a class-map to match VLAN 10 in flow 1	successfully
    ...    2	create a policy-map to bind the class-map and translate-cevlan-tag 20	successfully
    ...    3	apply the s-tag in ELAN mode and policy-map to the uni ethernet port1 and port2	successfully
    ...    4	send VLAN 10 traffic to uni ethernet port1 and port2	the two uni ports can receive the traffic from each other.


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4404      @subFeature=VLAN mapping: Change an S-Tag to another value      @globalid=2532666      @priority=P1      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12          @user_interface=CLI
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:1 create a class-map to match VLAN 10 in flow 1 successfully

    log    STEP:2 create a policy-map to bind the class-map and translate-cevlan-tag 20 successfully

    log    STEP:3 apply the s-tag in ELAN mode and policy-map to the uni ethernet port1 and port2 successfully

    log    STEP:4 send VLAN 10 traffic to uni ethernet port1 and port2 the two uni ports can receive the traffic from each other.
    run_dhcp_and_check_traffic    dserver    dcg    service_p1    subscriber_p1    traffic_loss_rate=${p_traffic_loss_rate}


*** Keywords ***
case setup
    [Documentation]
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan}    mode=ELAN
    prov_vlan_egress    eutA    ${p_service_vlan}    broadcast-flooding    ENABLED
    log    add service to two uni port
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=translate-cevlan-tag
    ...    cevlan=${p_translate_vlan}    cfg_prefix=sub1
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=translate-cevlan-tag
    ...    cevlan=${p_translate_vlan}    cfg_prefix=sub2
    log    create dhcp server and client
    create_dhcp_server    tg1    dserver    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.startup_ip}
    ...    ovlan=${p_match_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${p_dhcp_client.mac}    ovlan=${p_match_vlan}


case teardown
    [Documentation]
    log    delete the tg server and client
    Tg Delete All Traffic    tg1
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    log    remvoe service from uni port
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan=${p_translate_vlan}    cfg_prefix=sub1
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan}    ${p_service_vlan}    cevlan=${p_translate_vlan}    cfg_prefix=sub2
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan}