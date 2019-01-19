*** Settings ***
Documentation     Provision static host entry mff enabled with add 2 tags tag action. Generate upstream traffic. -> Traffic is forwarded.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_add_2_tags_static_host
    [Documentation]    Provision static host entry mff enabled with add 2 tags tag action. Generate upstream traffic. -> Traffic is forwarded.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1416    @subFeature=MAC_Forced_Forwarding    @globalid=2286185    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1416 setup
    [Teardown]   AXOS_E72_PARENT-TC-1416 teardown

    log    issue arp requests
    Tg Stc Device Transmit Arp    tg1    host1
    Tg Stc Device Transmit Arp    tg1    host2
    log     create traffic
    Tg Create Bound Untagged Stream On Port    tg1    us    subscriber_p1    host2    host1    l2_encap=ethernet_ii   
    ...     rate_mbps=1    l4_protocol=udp    udp_src_port=1000    udp_dst_port=1000   length_mode=fixed   frame_size=512     
    log   start traffic
    Tg Start Arp Nd On All Stream Blocks    tg1
    wait until keyword succeeds    5min    5s    check_l3_hosts    eutA    0    ${service_vlan1}    gateway1=${service_ip1}    l3-host=${service_ip1}    mac=${service_mac1} 
    start_capture    tg1    service_p1
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    stop_capture    tg1    service_p1
    log    ${TEST NAME}
    Tg Store Captured Packets    tg1    service_p1    /tmp/${TEST NAME}.pcap
    log    analyze captured packets
    analyze_packet_count_greater_than    /tmp/${TEST NAME}.pcap    eth.src==${subscriber_mac1} and eth.dst==${service_mac1} and vlan.id==${service_vlan1} and ip.src==${subscriber_ip1} and ip.dst==${subscriber_ip2}   0
    
*** Keywords ***
AXOS_E72_PARENT-TC-1416 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED 
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan1}    ctag_action=add-cevlan-tag    cvlan=${service_vlan2}    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=translate-cevlan-tag    cevlan=${service_vlan2}    cfg_prefix=auto2

    log    create static hosts
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${service_ip1} mac ${subscriber_mac1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${service_ip1} mac ${subscriber_mac2}
    Tg Stc Create Device On Port     tg1    host3    service_p1    intf_ip_addr=${service_ip1}    gateway_ip_addr=${subscriber_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${service_mac1}    encapsulation=ethernet_ii_qinq    vlan_outer_id=${service_vlan1}    vlan_id=${service_vlan2}
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${service_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    
    Tg Stc Create Device On Port     tg1    host2    subscriber_p1    intf_ip_addr=${subscriber_ip2}    gateway_ip_addr=${service_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan2}
AXOS_E72_PARENT-TC-1416 teardown
    [Documentation]  teardown
    [Arguments]

    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${subscriber_mac2}
    Tg Stc Delete Device On Port    tg1    host3    service_p1   mac_addr=${service_mac1}
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan1}    ${service_vlan2}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan=${service_vlan2}    cfg_prefix=auto2

    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}