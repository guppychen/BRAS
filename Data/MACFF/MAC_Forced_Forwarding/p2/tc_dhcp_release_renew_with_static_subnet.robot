*** Settings ***
Documentation     Provision ONT service with DHCP Snooping and mff enabled and a static subnet. Force a client to obtain a DHCP address. Generate continuous upstream traffic for static subnet. Release DHCP client address. Renew DHCP client address. -> Traffic flows for static subnet at all times through DHCP Release & Renew.
Resource          ./base.robot
Force Tags    @feature=MACFF   @author=wchen

*** Variables ***


*** Test Cases ***
tc_dhcp_release_renew_with_static_subnet
    [Documentation]    Provision ONT service with DHCP Snooping and mff enabled and a static subnet. Force a client to obtain a DHCP address. Generate continuous upstream traffic for static subnet. Release DHCP client address. Renew DHCP client address. -> Traffic flows for static subnet at all times through DHCP Release & Renew.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2947    @subFeature=MAC_Forced_Forwarding    @globalid=2392004    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-2947 setup
    [Teardown]   AXOS_E72_PARENT-TC-2947 teardown
    log    STEP:Provision ONT service with DHCP Snooping and mff enabled and a static subnet. Force a client to obtain a DHCP address. Generate continuous upstream traffic for static subnet. Release DHCP client address. Renew DHCP client address. -> Traffic flows for static subnet at all times through DHCP Release & Renew.
    
    log     issue arp request
    Tg Stc Device Transmit Arp    tg1    host1
    Tg Stc Device Transmit Arp    tg1    host2
    log    create traffic
    Tg Create Bound Single Tagged Stream On Port    tg1    us    subscriber_p1    host2    host1    vlan_id=${subscriber_vlan1}    l2_encap=ethernet_ii_vlan
    ...      vlan_user_priority=0    rate_mbps=1    l4_protocol=udp    udp_src_port=1000    udp_dst_port=1000   length_mode=fixed   frame_size=512     

    log     dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60 
    Tg Start Arp Nd On All Stream Blocks    tg1   
    log   start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    release
    log    traffic running
    sleep    ${traffic_run_time2}
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60 
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log    verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    log    release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    
*** Keywords ***
AXOS_E72_PARENT-TC-2947 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    dhcpp
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    dhcpp    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    log    create static subnet/host
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${network_ip1}    gateway1 ${gateway_ip1} mask ${mask_ip1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    subscriber_p1    intf_ip_addr=${subscriber_ip2}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan2}

    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000
    log    create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac3}    ${subscriber_vlan1}
AXOS_E72_PARENT-TC-2947 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
