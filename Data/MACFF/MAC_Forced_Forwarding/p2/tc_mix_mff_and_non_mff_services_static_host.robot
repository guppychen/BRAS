   
*** Settings ***
Documentation     Provision mff enabled on one service with a static host.  Provision a second service on the access interface without mff enabled.  Generate upstream UDP traffic.  -> All traffic is forwarded.
Resource          ./base.robot
Force Tags       @author=wchen    @feature=MACFF


*** Variables ***


*** Test Cases ***
tc_mix_mff_and_non_mff_services_static_host
    [Documentation]    Provision mff enabled on one service with a static host.  Provision a second service on the access interface without mff enabled.  Generate upstream UDP traffic.  -> All traffic is forwarded.
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1403    @subFeature=MAC_Forced_Forwarding    @globalid=2286172    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1403 setup
    [Teardown]   AXOS_E72_PARENT-TC-1403 teardown
    
    Tg Create Single Tagged Stream On Port    tg1    us1    subscriber_p1    subscriber_p1    vlan_id=${subscriber_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=${subscriber_mac2}    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip1}    ip_dst_addr=${subscriber_ip2}    l4_protocol=udp    udp_dst_port=6400   udp_src_port=6300   
    Tg Create Single Tagged Stream On Port    tg1    us2    service_p1    subscriber_p1    vlan_id=${subscriber_vlan3}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac4}    mac_dst=${service_mac4}    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip4}    ip_dst_addr=${service_ip4}    l4_protocol=udp    udp_dst_port=6400   udp_src_port=6300 
    Tg Start Arp Nd On All Stream Blocks    tg1
    wait until keyword succeeds    5min    10s    check_l3_hosts    eutA    0    ${service_vlan1}    gateway1=${gateway_ip1}    l3-host=${gateway_ip1}    mac=${gateway_mac1} 
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us1    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    us2    ${loss_rate}

*** Keywords ***
AXOS_E72_PARENT-TC-1403 setup
    [Documentation]    setup
    [Arguments]
    log    setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    dhcpp
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    dhcpp    mff=ENABLED
    prov_vlan    eutA    ${service_vlan2}    dhcpp  
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1},${service_vlan2}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan3}    ${service_vlan2}    cevlan_action=remove-cevlan    cfg_prefix=auto3
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} mac ${subscriber_mac1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1} mac ${subscriber_mac2}

    log    create dhcp servers

AXOS_E72_PARENT-TC-1403 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan3}    ${service_vlan2}    cfg_prefix=auto3
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1},${service_vlan2}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    vlan    ${service_vlan2}
    log    delete dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
