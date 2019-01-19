*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=VLAN      @author=Anson Zhang

*** Variables ***


*** Test Cases ***
tc_ELINE_between_two_uni_port
    [Documentation]

    ...    1	create a class-map to match VLAN 10 in flow 1	successfully
    ...    2	create a policy-map to bind the class-map and remove-cevlan	successfully
    ...    3	apply the s-tag in ELINE and policy-map to the uni ethernet port1 and port2	successfully
    ...    4	send VLAN 10 traffic to uni ethernet port1 and port2	the two uni ethernet ports can receive the traffic from each other.


    [Tags]     @tcid=AXOS_E72_PARENT-TC-4387    @subFeature=VLAN mapping: change C-Tag to an S-Tag    @globalid=2532643    @priority=P1    @eut=10GE-12    @user_interface=CLI    @PASS=true
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:1 create a class-map to match VLAN 10 in flow 1 successfully

    log    STEP:2 create a policy-map to bind the class-map and remove-cevlan successfully

    log    STEP:3 apply the s-tag in ELINE and policy-map to the uni ethernet port1 and port2 successfully

    log    STEP:4 send VLAN 10 traffic to uni ethernet port1 and port2 the two uni ethernet ports can receive the traffic from each other.
    log    start the dhcp server and client
    run_dhcp_and_check_traffic    dserver    dcg    service_p1    subscriber_p1    traffic_loss_rate=${p_traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]
    log    create vlan
    prov_vlan    eutA    ${p_service_vlan}    mode=ELINE
    log    add service to two uni port
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=remove-cevlan
    ...    cfg_prefix=sub1
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan}    ${p_service_vlan}    cevlan_action=remove-cevlan
    ...    cfg_prefix=sub2
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
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_service_vlan}    cfg_prefix=sub1
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan}    ${p_service_vlan}    cfg_prefix=sub2
    log    delete vlan and profile
    delete_config_object    eutA    vlan    ${p_service_vlan}