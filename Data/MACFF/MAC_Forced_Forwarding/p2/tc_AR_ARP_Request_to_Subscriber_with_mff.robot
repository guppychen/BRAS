*** Settings ***
Documentation     Provision mff on access interface with AR and clients attached. Generate an ARP Request from the AR for the subscriber. Capture ARP traffic at the client and AR. -> All ARP REQUESTs from AR are forwarded to subscriber.  An ARP REPLY for each ARP REQUEST is received at AR. 
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen
*** Variables ***
*** Test Cases ***
tc_AR_ARP_Request_to_Subscriber_with_mff
    [Documentation]    Provision mff on access interface with AR and clients attached. Generate an ARP Request from the AR for the subscriber. Capture ARP traffic at the client and AR. -> All ARP REQUESTs from AR are forwarded to subscriber.  An ARP REPLY for each ARP REQUEST is received at AR. 
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1424    @subFeature=MAC_Forced_Forwarding    @globalid=2286193    @priority=P1   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1424 setup
    [Teardown]   AXOS_E72_PARENT-TC-1424 teardown
    log    start capture
    start_capture    tg1    subscriber_p1
    log    issue arp request
    Tg Stc Device Transmit Arp    tg1    host2 
    log    stop capture
    stop_capture    tg1    subscriber_p1
    Tg Store Captured Packets    tg1    subscriber_p1    /tmp/subscriber_arp.pcap
    log    verify arp request is received
    analyze_packet_count_greater_than    /tmp/subscriber_arp.pcap    eth.src==${service_mac1} and eth.dst==ff:ff:ff:ff:ff:ff and vlan.id==${subscriber_vlan1}    0
    log    start capture
    start_capture    tg1    service_p1
    log    issue arp request
    Tg Stc Device Transmit Arp    tg1    host2
    log    stop capture
    stop_capture    tg1    service_p1
    Tg Store Captured Packets    tg1    service_p1    /tmp/service_arp.pcap
    log    verify arp reply is received
    analyze_packet_count_greater_than    /tmp/service_arp.pcap    eth.src==${subscriber_mac1} and eth.dst==${service_mac1} and vlan.id==${service_vlan1}    0
*** Keywords ***
AXOS_E72_PARENT-TC-1424 setup
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
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${service_ip1}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${service_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    service_p1    intf_ip_addr=${service_ip1}    gateway_ip_addr=${subscriber_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${service_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan1}
AXOS_E72_PARENT-TC-1424 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    log    delete devices
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${service_mac1}
    run keyword and ignore error    Tg Stop All Traffic    tg1

    log    remove static host
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove service
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
