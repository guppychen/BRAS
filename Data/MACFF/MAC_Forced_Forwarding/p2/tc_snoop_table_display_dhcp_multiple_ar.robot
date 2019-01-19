*** Settings ***
Documentation     Enable mff and dhcp snoop. Provision the dhcp server to provider multiple ARs. Force a client to obtain an IP address. Display snoop table.  -> DHCP client and multiple ARs are displayed in the snoop table.

Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen
*** Variables ***

*** Test Cases ***
tc_snoop_table_display_dhcp_multiple_ar
    [Documentation]    Enable mff and dhcp snoop. Provision the dhcp server to provider multiple ARs. Force a client to obtain an IP address. Display snoop table.  -> DHCP client and multiple ARs are displayed in the snoop table.
    
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2984    @subFeature=MAC_Forced_Forwarding    @globalid=2439211    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-2984 setup
    [Teardown]   AXOS_E72_PARENT-TC-2984 teardown
    log    STEP:Provision service with DHCP Snooping and mff enabled. Force a client to obtain a DHCP address with a fairly short lease time. Generate continuous upstream UDP traffic. Wait for renew to occur. -> Traffic continues to flow after the DHCP address renew.
    log   dhcp negotiation
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dgroup1    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    60
    ${res}    cli    eutA    show l3
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip1}(.*?)up-down-state?
    Log    ${grp1}
    log     verify AR info
    should match regexp    ${grp1}    mac\\s+${gateway_mac1}
    should match regexp    ${grp1}    interface\\s+${service_model.service_point2.member.interface1}
    log     verify dhcp lease info
    ${match}    ${grp2}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${pool_start_ip}(.*?)lease-first-acquired
    should match regexp    ${grp2}    gateway1\\s+${gateway_ip1}
    should match regexp    ${grp2}    gateway2\\s+${gateway_ip2}
    should match regexp    ${grp2}    gateway3\\s+${gateway_ip3}
    ${match}    ${grp3}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip2}(.*?)up-down-state?
    Log    ${grp3}
    log     verify AR info
    should match regexp    ${grp3}    mac\\s+${gateway_mac2}
    should match regexp    ${grp3}    interface\\s+${service_model.service_point2.member.interface1}
    ${match}    ${grp4}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip3}(.*?)up-down-state?
    Log    ${grp4}
    log     verify AR info
    should match regexp    ${grp4}    mac\\s+${gateway_mac3}
    should match regexp    ${grp4}    interface\\s+${service_model.service_point2.member.interface1}
    log   release dhcp leases
    Tg Control Dhcp Client    tg1    dgroup1    stop
    Tg Control Dhcp Server    tg1    dserver    stop

*** Keywords ***
AXOS_E72_PARENT-TC-2984 setup
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
    log    create dhcp server
    Tg Create Dhcp Server On Port    tg1    dserver   service_p1    local_mac=${service_mac1}   
    ...    ip_version=4    ip_address=${service_ip1}    encapsulation=ETHERNET_II_VLAN    vlan_id=${service_vlan1}
    ...    dhcp_ack_options=1    dhcp_ack_router_adddress=${gateway_ip3} ${gateway_ip2} ${gateway_ip1}    
    ...    ipaddress_pool=${pool_start_ip}    ipaddress_count=100    lease_time=1000
    log   create dhcp clients
    create_dhcp_client    tg1    dclient1    subscriber_p1    dgroup1    ${subscriber_mac1}    ${subscriber_vlan1}
AXOS_E72_PARENT-TC-2984 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    dclient1
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    dserver
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
    delete_config_object    eutA    l2-dhcp-profile    dhcpp
