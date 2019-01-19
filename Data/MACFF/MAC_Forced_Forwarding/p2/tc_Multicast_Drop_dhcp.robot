    
*** Settings ***
Documentation     Provision mff service and dhcp snoop enabled. Force a client to obtain an IP address. From the dhcp client generate multicast traffic. -> No traffic is forwarded.
Resource          ./base.robot
Force Tags       @author=wchen    @feature=MACFF

*** Variables ***


*** Test Cases ***
tc_Multicast_Drop_dhcp
    [Documentation]    Provision mff service and dhcp snoop enabled. Force a client to obtain an IP address. From the dhcp client generate multicast traffic. -> No traffic is forwarded.
    [Tags]    @subFeature=MAC_Forced_Forwarding    @tcid=AXOS_E72_PARENT-TC-2963    @globalid=2423101    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-2963 setup
    [Teardown]   AXOS_E72_PARENT-TC-2963 teardown
    log   dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    log    create traffic
    Tg Create Single Tagged Stream On Port    tg1    us    service_p1    subscriber_p1    vlan_id=${subscriber_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=01:00:5e:0e:01:01    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip1}    ip_dst_addr=225.14.1.1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   analyze traffic result
    verify traffic stream all pkt loss    tg1    us

    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Server    tg1    dserver    stop
*** Keywords ***
AXOS_E72_PARENT-TC-2963 setup
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
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=100
    log   create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
    
AXOS_E72_PARENT-TC-2963 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static host
    log    remove service
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}   
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
