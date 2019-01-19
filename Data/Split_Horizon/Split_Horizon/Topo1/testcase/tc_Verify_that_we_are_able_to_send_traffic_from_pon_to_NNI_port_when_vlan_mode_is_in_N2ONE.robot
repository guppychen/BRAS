*** Settings ***
Documentation     Verify that we are able to send traffic from pon to NNI port when vlan mode is in N2ONE.
Resource          ./base.robot
Force Tags        @feature=split_horizon    @subfeature=split_horizon

*** Variables ***

*** Test Cases ***
tc_Verify_that_we_are_able_to_send_traffic_from_pon_to_NNI_port_when_vlan_mode_is_in_N2ONE
    [Documentation]    Verify that we are able to send traffic from pon to NNI port when vlan mode is in N2ONE.
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-388    @globalid=2204701    @eut=NGPON2-4    @priority=P1
    [Setup]      setup
    [Teardown]   teardown
    Tg Start Arp Nd On All Devices    tg1
    Tg Start Arp Nd On All Stream Blocks      tg1
    log    send traffic from ONT port to ethernet interface(ethernet interface NNI).
    Tg Create Single Tagged Stream On Port    tg1    upstream    service_p1    subscriber_p1    vlan_id=${p_match_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=${service_mac1}    rate_pps=${rate_pps}    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip}    ip_dst_addr=${service_ip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63

    log    check all traffic can pass
#    Tg Start All Traffic     tg1
#    # wait to run
#    sleep    ${sleep_time}
#    Tg Stop All Traffic    tg1
#    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    # wait enough time to run
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # wait to stop
    sleep    ${wait_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    upstream    ${loss_rate}

*** Keywords ***
setup
    [Documentation]    setup
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    mac-learning=enable
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