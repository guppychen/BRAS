*** Settings ***
Documentation     Force a host to obtain a DHCP address. Display snoop entries. Create a static snoop entry using a different IP than obtained and no MAC. Generate upstream ARP using same MAC for static host as the dynamic entry. Display the snoop entries. -> The dynamic entry is no longer present and the static entry has the learned MAC.
Resource          ./base.robot
Force Tags    @feature=MACFF   @author=wchen

*** Variables ***


*** Test Cases ***
tc_static_overwrite_of_dhcp
    [Documentation]    Force a host to obtain a DHCP address. Display snoop entries. Create a static snoop entry using a different IP than obtained and no MAC. Generate upstream ARP using same MAC for static host as the dynamic entry. Display the snoop entries. -> The dynamic entry is no longer present and the static entry has the learned MAC.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1390    @subFeature=MAC_Forced_Forwarding    @globalid=2286159    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1390 setup
    [Teardown]   AXOS_E72_PARENT-TC-1390 teardown
    log     Force a host to obtain a DHCP address. Display snoop entries. Create a static snoop entry using a different IP than obtained and no MAC. Generate upstream ARP using same MAC for static host as the dynamic entry. Display the snoop entries. -> The dynamic entry is no longer present and the static entry has the learned MAC.
    log     dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60  
    Tg Stc Device Transmit Arp    tg1    host1
    log    check snoop table
    ${res}    cli    eutA    show l3-hosts
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${subscriber_ip1}(.*)up-down-state
    should match regexp    ${grp1}    mac\\s+${subscriber_mac1}
    should match regexp    ${grp1}    gateway1\\s+${gateway_ip1}
    log    release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    
*** Keywords ***
AXOS_E72_PARENT-TC-1390 setup
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
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan  
    log    create static hosts
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} 
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000
    log    create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    
AXOS_E72_PARENT-TC-1390 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac2}
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
