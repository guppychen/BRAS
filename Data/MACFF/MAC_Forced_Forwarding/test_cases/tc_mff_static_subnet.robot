*** Settings ***
Documentation     Provision mff enabled with a static subnet entry. Generate upstream UDP traffic. -> All traffic is forwarded.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_mff_static_subnet
    [Documentation]    Provision mff enabled with a static subnet entry. Generate upstream UDP traffic. -> All traffic is forwarded.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1379    @subFeature=MAC_Forced_Forwarding    @globalid=2286166    @priority=P1   @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1379 setup
    [Teardown]   AXOS_E72_PARENT-TC-1379 teardown
    log    STEP:Provision mff enabled with a static subnet entry. Generate UDP traffic in each direction. -> All traffic is forwarded.
    log    issue arp requests  
    Tg Stc Device Transmit Arp    tg1    host1
    Tg Stc Device Transmit Arp    tg1    host2

    # add by llin for AT-3139 2017.10.9
    log    show L3 host
    wait_mff_dynamic_host_table       eutA       ${service_model.service_point2.member.interface1}
    # add by llin for AT-3139 2017.10.9

    log    create traffic
    Tg Create Bound Single Tagged Stream On Port    tg1    us    subscriber_p1    host2    host1    vlan_id=${subscriber_vlan1}    l2_encap=ethernet_ii_vlan
    ...      vlan_user_priority=0    rate_mbps=1    l4_protocol=udp    udp_src_port=1000    udp_dst_port=1000   length_mode=fixed   frame_size=512     
    tg modify traffic stream    tg1    us    mac_dst=${gateway_mac1}
    log     start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log     verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}

*** Keywords ***
AXOS_E72_PARENT-TC-1379 setup
    [Documentation]  setup
    [Arguments]
    log    setup

    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    log    create static host/subnet
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${network_ip1}    gateway1 ${gateway_ip1} mask ${mask_ip1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    subscriber_p1    intf_ip_addr=${subscriber_ip2}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan2}
    
AXOS_E72_PARENT-TC-1379 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    log    delete devices
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${subscriber_mac2}
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static host/subnet
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
