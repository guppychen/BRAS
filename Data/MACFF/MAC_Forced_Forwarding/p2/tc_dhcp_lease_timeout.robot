*** Settings ***
Documentation    Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream traffic. Stop or disconnect DHCP server. Wait for the lease timeout to occur. -> Traffic stops to flow after the DHCP lease timeout
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_dhcp_lease_timeout
    [Documentation]    Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream traffic. Stop or disconnect DHCP server. Wait for the lease timeout to occur. -> Traffic stops to flow after the DHCP lease timeout
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1392    @subFeature=MAC_Forced_Forwarding    @globalid=2286161    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1392 setup
    [Teardown]   AXOS_E72_PARENT-TC-1392 teardown
    
    log    dhcp negotiation
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
    log   disable dhcp server
    Tg Control Dhcp Server    tg1    dserver    stop
    ${t2} =    Evaluate    str(${lease_time2})+"s"
    log   wait for lease to timeout
    sleep    ${t2}
    # AT-4518 add by llin to wait at most 20 seconds
    wait until keyword succeeds    20   2    check_l3_hosts    eutA    0
    # AT-4518 add by llin
    log    clear traffic statistics
    Tg Clear Traffic Stats    tg1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    Tg Stop All Traffic    tg1
    log    verify traffic loss
    verify traffic stream all pkt loss    tg1    us
    log    release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Client    tg1    dgroup2    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
AXOS_E72_PARENT-TC-1392 setup
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
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}
    ...    ip_version=4    ip_address=${service_ip1}    ip_gateway=${gateway_ip1}     encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip1}
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=${lease_time2}
    log    create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}    retry_attempts=4   enable_auto_retry=true  
    create_dhcp_client    tg1    dclient2    subscriber_p1    dgroup2    ${subscriber_mac2}    ${subscriber_vlan2}    retry_attempts=4   enable_auto_retry=true
AXOS_E72_PARENT-TC-1392 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient2
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log   remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
