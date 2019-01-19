*** Settings ***
Documentation     Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream UDP traffic. Release client address. Renew client address. -> Traffic flows only when an active DHCP lease for the client exists.
Resource          ./base.robot
Force Tags      @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_dhcp_release_renew
    [Documentation]    Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream UDP traffic. Release client address. Renew client address. -> Traffic flows only when an active DHCP lease for the client exists.
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1382    @subFeature=MAC_Forced_Forwarding    @globalid=2286151    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    
    log     dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Control Dhcp Client    tg1    dgroup2    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    90
    log    create traffic
    create_bound_traffic_udp    tg1    us    subscriber_p1    dgroup2   dgroup1    1
    Tg Start Arp Nd On All Stream Blocks    tg1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log    verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    release
    Tg Control Dhcp Client    tg1    dgroup2    release
    Tg Clear Traffic Stats    tg1
    log    start traffic
    Tg Start All Traffic    tg1
    log     traffic running
    sleep    ${traffic_run_time2}
    log     stop traffic
    Tg Stop All Traffic    tg1
    log     verify traffic loss
    verify traffic stream all pkt loss    tg1    us
    log     dhcp negotiation
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Control Dhcp Client    tg1    dgroup2    start     
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60   
    log     clear traffic statistics
    Tg Clear Traffic Stats    tg1
    log     start traffic
    Tg Start All Traffic    tg1
    log     traffic running
    sleep    ${traffic_run_time2}
    log     stop traffic
    Tg Stop All Traffic    tg1
    log     verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    log    release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Client    tg1    dgroup2    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
case setup
    [Documentation]    set up
    [Arguments]
    log    case setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    dhcpp
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    dhcpp    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=100
    log    create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
    create_dhcp_client    tg1    dclient2    subscriber_p1    dgroup2    ${subscriber_mac2}    ${subscriber_vlan2}

case teardown
    [Documentation]    tear down
    [Arguments]
    log    case teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient2
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
