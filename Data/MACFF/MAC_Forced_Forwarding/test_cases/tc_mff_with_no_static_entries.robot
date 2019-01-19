    
*** Settings ***
Documentation     Provision mff enabled with no static entries. Generate UDP traffic in the subscriber-to-network direction. -> No traffic is forwarded.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_mff_with_no_static_entries
    [Documentation]    Provision mff enabled with no static entries. Generate UDP traffic in the subscriber-to-network direction. -> No traffic is forwarded.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1394    @subFeature=MAC_Forced_Forwarding    @globalid=2286163    @priority=P1   @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1394 setup
    [Teardown]   AXOS_E72_PARENT-TC-1394 teardown
    log    STEP:Provision mff enabled with no static entries. Generate UDP traffic in the subscriber-to-network direction. -> No traffic is forwarded.
    log    create traffic
    Tg Create Single Tagged Stream On Port    tg1    us    service_p1    subscriber_p1    vlan_id=${subscriber_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=${service_mac1}    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip1}    ip_dst_addr=${service_ip1}    l4_protocol=udp    udp_dst_port=6400   udp_src_port=6300 
    log     start traffic   
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log    verify traffic loss
    verify traffic stream all pkt loss    tg1    us


*** Keywords ***
AXOS_E72_PARENT-TC-1394 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan 

AXOS_E72_PARENT-TC-1394 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log     remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}   
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
