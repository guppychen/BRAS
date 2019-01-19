   
*** Settings ***
Documentation     Provision DHCP Snooping and mff enabled on one service and force a client to obtain a DHCP address. Provision a second service the access interface with DHCP Snooping enabled and mff disabled and force a second client to obtain a DHCP address. Generate UDP traffic in each direction for each client. -> All traffic is forwarded.
Resource          ./base.robot
Force Tags       @author=wchen    @feature=MACFF


*** Variables ***


*** Test Cases ***
tc_mix_mff_and_non_mff_services
    [Documentation]    Provision service with DHCP Snooping, mff enabled & IP Source Verify disabled. Force a client to obtain a DHCP address using a rebind time longer than the time it takes to execute test case. Generate continuous upstream UDP traffic. -> All traffic is forwarded.
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1384    @subFeature=MAC_Forced_Forwarding    @globalid=2286153    @priority=P1   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1384 setup
    [Teardown]   AXOS_E72_PARENT-TC-1384 teardown
    log    STEP:Provision DHCP Snooping and mff enabled on one service and force a client to obtain a DHCP address. Provision a second service the access interface with DHCP Snooping enabled and mff disabled and force a second client to obtain a DHCP address. Generate UDP traffic in each direction for each client. -> All traffic is forwarded.
    
    log    dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver1    start
    Tg Control Dhcp Server    tg1    dserver2    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Control Dhcp Client    tg1    dgroup2    start
    Tg Control Dhcp Client    tg1    dgroup3    start
    Tg Control Dhcp Client    tg1    dgroup4    start
    tg save config into file   tg1   /tmp/mff.xml
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    ${res}    cli    eutA    show l3

    log    create traffic
    create_bound_traffic_udp    tg1    us1    subscriber_p1    dgroup2   dgroup1    1
    create_bound_traffic_udp    tg1    us3    subscriber_p1    dserver2   dgroup3    1
    Tg Start Arp Nd On All Stream Blocks    tg1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us1    ${loss_rate}
    TG Verify Traffic Loss For Stream Is Within    tg1    us3    ${loss_rate}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Client    tg1    dgroup2    stop
    Tg Control Dhcp Client    tg1    dgroup3    stop
    Tg Control Dhcp Client    tg1    dgroup4    stop
    Tg Control Dhcp Server    tg1    dserver1    stop
    Tg Control Dhcp Server    tg1    dserver2    stop

*** Keywords ***
AXOS_E72_PARENT-TC-1384 setup
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
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan4}    ${service_vlan2}    cevlan_action=remove-cevlan    cfg_prefix=auto4
    log    create dhcp servers
    Tg Create Dhcp Server On Port    tg1    dserver1   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000  
    Tg Create Dhcp Server On Port    tg1    dserver2   service_p1    local_mac=${service_mac4}
    ...    ip_version=4    ip_address=${service_ip4}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan2}
    ...    ipaddress_pool=${pool_start_ip4}    ipaddress_count=100    lease_time=1000  
    log   create dhcp clients  
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
    create_dhcp_client    tg1    dclient2    subscriber_p1    dgroup2    ${subscriber_mac2}    ${subscriber_vlan2}
    create_dhcp_client    tg1    dclient3    subscriber_p1    dgroup3    ${subscriber_mac3}    ${subscriber_vlan3}
    create_dhcp_client    tg1    dclient4    subscriber_p1    dgroup4    ${subscriber_mac4}    ${subscriber_vlan4}
AXOS_E72_PARENT-TC-1384 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient2
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient3
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient4
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver2
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan3}    ${service_vlan2}    cfg_prefix=auto3
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan4}    ${service_vlan2}    cfg_prefix=auto4
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1},${service_vlan2}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    vlan    ${service_vlan2}
    log    delete dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
