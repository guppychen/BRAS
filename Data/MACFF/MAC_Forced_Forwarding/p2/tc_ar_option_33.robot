*** Settings ***
Documentation     Enable mff and provision DHCP server with option 33. Force a client to obtain a DHCP address. Generate continuous upstream UDP traffic. -> Traffic is forwarded and proxied by AR learned throught option 33.
...               This configuration enables all of the Access Interface security features, providing the highest level of security for the Access Network.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen 
*** Variables ***

*** Test Cases ***
tc_ar_option_33
    [Documentation]    Enable mff and provision DHCP server with option 33. Force a client to obtain a DHCP address. Generate continuous upstream UDP traffic. -> Traffic is forwarded and proxied by AR learned throught option 33.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1428    @subFeature=MAC_Forced_Forwarding    @globalid=2286197    @priority=P1   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1428 setup
    [Teardown]   AXOS_E72_PARENT-TC-1428 teardown
    log    STEP:Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream UDP traffic. Wait for renew to occur. -> Traffic continues to flow after the DHCP address renew.
    log   dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Control Dhcp Client    tg1    dgroup2    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    log    create traffic
    create_bound_traffic_udp    tg1    us    subscriber_p1    dgroup2   dgroup1    1
    Tg Start Arp Nd On All Stream Blocks    tg1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time1}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   verify traffic pass
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Client    tg1    dgroup2    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
AXOS_E72_PARENT-TC-1428 setup
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
    ...    dhcp_ack_options=1    
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000
    Tg Create Dhcp Server Option     tg1    dserver   33    ac1e650aac1e6501    MsgType=OFFER|ACK    EnableWildcards=TRUE 	HexValue=TRUE
    log   create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
    create_dhcp_client    tg1    dclient2    subscriber_p1    dgroup2    ${subscriber_mac2}    ${subscriber_vlan2}
AXOS_E72_PARENT-TC-1428 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient2
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
