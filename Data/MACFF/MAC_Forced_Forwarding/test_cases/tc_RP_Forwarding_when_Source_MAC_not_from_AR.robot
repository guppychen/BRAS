*** Settings ***
Documentation     Provision mff with static host with MAC and AR present. From network location ARP for provisioned static host. Capture traffic at the AR and client. -> No ARP frames are forwarded on the subscriber interface. ARP Replys are proxied with the non-AR network device receiving an ARP REPLY for each ARP REQUEST.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen
*** Variables ***
*** Test Cases ***
tc_RP_Forwarding_when_Source_MAC_not_from_AR
    [Documentation]    Provision mff with static host with MAC and AR present. From network location ARP for provisioned static host. Capture traffic at the AR and client. -> No ARP frames are forwarded on the subscriber interface. ARP Replys are proxied with the non-AR network device receiving an ARP REPLY for each ARP REQUEST.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1425   @subFeature=MAC_Forced_Forwarding    @globalid=2286194    @priority=P1   @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1425 setup
    [Teardown]   AXOS_E72_PARENT-TC-1425 teardown
    log    STEP:Provision mff with static host with MAC and AR present. From network location ARP for provisioned static host. Capture traffic at the AR and client. -> No ARP frames are forwarded on the subscriber interface. ARP Replys are proxied with the non-AR network device receiving an ARP REPLY for each ARP REQUEST.
    log    start capture
    start_capture    tg1    subscriber_p1
    log    issue arp request
    Tg Stc Device Transmit Arp    tg1    host2 
    log    stop capture
    stop_capture    tg1    subscriber_p1
    log    verify no arp frames are forwarded on the subscriber interface
    verify_no_traffic_on_port_with_filter    tg1   subscriber_p1    eth.src==${service_mac2} and vlan.id==${subscriber_vlan1}
    log    start capture
    start_capture    tg1    service_p1
    log    issue arp request
    Tg Stc Device Transmit Arp    tg1    host2
    log    stop capture
    stop_capture    tg1    service_p1
    Tg Store Captured Packets    tg1    service_p1    /tmp/stcarp.pcap
    log    verify arp reply is proxied
    analyze_packet_count_greater_than    /tmp/stcarp.pcap    eth.src==${subscriber_mac1} and eth.dst==${service_mac2} and vlan.id==${service_vlan1}    0
*** Keywords ***
AXOS_E72_PARENT-TC-1425 setup
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
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} mac ${subscriber_mac1}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    service_p1    intf_ip_addr=${service_ip2}    gateway_ip_addr=${subscriber_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${service_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan1}
AXOS_E72_PARENT-TC-1425 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    log    delete devices
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    service_p1   mac_addr=${service_mac2}
    log    remove static host
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove service
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
