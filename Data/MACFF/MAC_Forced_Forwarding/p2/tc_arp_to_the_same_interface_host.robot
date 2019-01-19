    
*** Settings ***
Documentation     Provision mff enabled with static host entries belong to the same subscriber interface. Issue an ARP request from the subscriber interface with target IP belongs to an IP host associated with the same subscriber interface. -> ARP request is discarded.
Resource          ./base.robot
Force Tags       @author=wchen    @feature=MACFF

*** Variables ***


*** Test Cases ***
tc_arp_to_the_same_interface_host
    [Documentation]    Provision mff enabled with static host entries belong to the same subscriber interface. Issue an ARP request from the subscriber interface with target IP belongs to an IP host associated with the same subscriber interface. -> ARP request is discarded.
    [Tags]    @subFeature=MAC_Forced_Forwarding    @tcid=AXOS_E72_PARENT-TC-1434    @globalid=2286203    @priority=P1   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1434 setup
    [Teardown]   AXOS_E72_PARENT-TC-1434 teardown
  
    
    log    start capture
    start_capture    tg1    service_p1
    log    issue arp request
    Tg Stc Device Transmit Arp    tg1    host1
    log    stop capture
    stop_capture    tg1    service_p1
    verify_no_traffic_on_port_with_filter    tg1   service_p1    eth.src==${subscriber_mac1} and vlan.id==${service_vlan1} and arp.dst.proto_ipv4 == ${subscriber_ip2}
    
*** Keywords ***
AXOS_E72_PARENT-TC-1434 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan 
    log    create static host
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1} mac ${subscriber_mac2}
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${subscriber_ip2}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    subscriber_p1    intf_ip_addr=${subscriber_ip2}    gateway_ip_addr=${subscriber_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}   
AXOS_E72_PARENT-TC-1434 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${subscriber_mac2}
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static host
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    
    log    remove service
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}   
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
