   
*** Settings ***
Documentation     Enable mff and dhcp snoop. Provision a service with add and change tag tag action. Force a client to obtain an IP address. Display snoop table.  -> DHCP client and AR are displayed in the snoop table with inner vlan.

Resource          ./base.robot
Force Tags     @feature=MACFF    @author=wchen


*** Variables ***


*** Test Cases ***
tc_snoop_table_display_dhcp_add_and_change_tag
    [Documentation]    Enable mff and dhcp snoop. Provision a service with add and change tag tag action. Force a client to obtain an IP address. Display snoop table.  -> DHCP client and AR are displayed in the snoop table with inner vlan.
    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-2979    @subFeature=MAC_Forced_Forwarding    @globalid=2437015    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-2979 setup
    [Teardown]   AXOS_E72_PARENT-TC-2979 teardown
    
    log    dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    log    check snoop table
    ${res}    cli    eutA    show l3-hosts
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip1}(.*)l3-host
    Log    ${grp1}
    log     verify AR info
    should match regexp    ${grp1}    mac\\s+${gateway_mac1}
    should match regexp    ${grp1}    interface\\s+${service_model.service_point2.member.interface1}
    log     verify dhcp lease info
    ${match}    ${grp2}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${pool_start_ip}(.*)lease-first-acquired
    should match regexp    ${grp2}    gateway1\\s+${gateway_ip1}
    should match regexp    ${grp2}    inner-vlan\\s+${service_vlan2}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
AXOS_E72_PARENT-TC-2979 setup
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
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=translate-cevlan-tag    cevlan=${service_vlan2}    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1} mac ${subscriber_mac2}
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_QINQ    vlan_id=${service_vlan2}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}    vlan_outer_id=${service_vlan1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000  
    log   create dhcp clients  
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}  
 
AXOS_E72_PARENT-TC-2979 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan=${service_vlan2}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    log    delete dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
