*** Settings ***
Documentation     Verify that we are able to send traffic from NNI to pon port when vlan mode is in ELINE .
Resource          ./base.robot
Force Tags        @feature=split_horizon    @subfeature=split_horizon

*** Variables ***


*** Test Cases ***
tc_Verify_that_we_are_able_to_send_traffic_from_NNI_to_pon_port_when_vlan_mode_is_in_ELINE
    [Documentation]    Verify that we are able to send traffic from NNI to pon port when vlan mode is in ELINE .
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-402    @globalid=2262108    @eut=NGPON2-4    @priority=P2
    [Setup]      setup
    [Teardown]   teardown
    Tg Start Arp Nd On All Devices    tg1
    Tg Start Arp Nd On All Stream Blocks      tg1
    log    send traffic from the ethernet interface(ethernet interface NNI) to ONT port
    Tg Create Single Tagged Stream On Port    tg1    downstream    subscriber_p1    service_p1    vlan_id=${p_data_vlan}    vlan_user_priority=0
    ...    mac_src=${service_mac1}    mac_dst=${subscriber_mac1}    rate_pps=${rate_pps}    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${service_ip}    ip_dst_addr=${subscriber_ip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63

    log    check all traffic can pass
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    downstream    ${loss_rate}

*** Keywords ***
setup
    [Documentation]    setup
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    mac-learning=enable    mode=ELINE
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}    cevlan_action=remove-cevlan

teardown
    [Documentation]    teardown
    run keyword and ignore error  tg delete all traffic    tg1

    log    subscriber_point remove_svc
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan1}    ${p_data_vlan}
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan}
