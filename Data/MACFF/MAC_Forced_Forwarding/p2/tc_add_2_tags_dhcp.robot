   
*** Settings ***
Documentation     Provision mff enabled with  add 2 tags tag action. Force a client to obtain a DHCP address. Generate upstream traffic. -> Traffic is forwarded.

Resource          ./base.robot
Force Tags     @feature=MACFF    @author=wchen


*** Variables ***


*** Test Cases ***
tc_add_2tags_dhcp
    [Documentation]    Provision mff enabled with add 2 tags tag action. Force a client to obtain a DHCP address. Generate upstream traffic. -> Traffic is forwarded.
    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-2961    @subFeature=MAC_Forced_Forwarding    @globalid=2421304    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-2961 setup
    [Teardown]   AXOS_E72_PARENT-TC-2961 teardown
    
    log    dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    log    create traffic
    Tg Create Untagged Stream On Port    tg1    us    subscriber_p1    subscriber_p1   
    ...    mac_src=${subscriber_mac1}    mac_dst=${subscriber_mac2}    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${pool_start_ip}    ip_dst_addr=${subscriber_ip2}    l4_protocol=udp    udp_dst_port=6400   udp_src_port=6300 

    log    start capture traffic
    start_capture    tg1    service_p2

    log    start traffic
    tg save config into file        tg1      /tmp/mff.xml
    Tg Start Arp Nd On All Devices      tg1
    Tg Start Arp Nd On All Stream Blocks    tg1
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    stop_capture    tg1    service_p2
    log    ${TEST NAME}
    Tg Store Captured Packets    tg1    service_p2    /tmp/${TEST NAME}.pcap
    log    analyze captured packets
    analyze_packet_count_greater_than    /tmp/${TEST NAME}.pcap    eth.src==${subscriber_mac1} and eth.dst==${service_mac2} and vlan.id==${service_vlan1} and ip.src==${pool_start_ip} and ip.dst==${subscriber_ip2}   0

    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
AXOS_E72_PARENT-TC-2961 setup
    [Documentation]    setup
    [Arguments]
    log    setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    dhcpp
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    dhcpp    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan1}    ctag_action=add-cevlan-tag    cvlan=${service_vlan2}    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=translate-cevlan-tag    cevlan=${service_vlan2}    cfg_prefix=auto2
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${service_ip2} mac ${subscriber_mac2}
   
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${service_ip2}     encapsulation=ETHERNET_II_QINQ    vlan_id=${service_vlan2}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${service_ip2}    vlan_outer_id=${service_vlan1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000  
    log   create dhcp clients  
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}   
    Tg Stc Create Device On Port     tg1    host2    subscriber_p1    intf_ip_addr=${subscriber_ip2}    gateway_ip_addr=${service_ip2}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan2}
    Tg Stc Create Device On Port     tg1    host1    service_p2    intf_ip_addr=${service_ip2}    gateway_ip_addr=${subscriber_ip2}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${service_mac2}    encapsulation=ethernet_ii_qinq    vlan_id=${service_vlan2}    vlan_outer_id=${service_vlan1} 
AXOS_E72_PARENT-TC-2961 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${subscriber_mac2}
    Tg Stc Delete Device On Port    tg1    host1    service_p2   mac_addr=${service_mac2}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan1}    ${service_vlan2}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan=${service_vlan2}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    log    delete dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
