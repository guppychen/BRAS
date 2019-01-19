*** Settings ***
Documentation     Provision mff on ONT with AR and clients attached. Display resolved AR. Modify AR MAC. Force ARP from client for AR. Display resolved AR. -> AR MAC modified from the old to the new MAC after client ARP.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_Modify_the_AR_MAC
    [Documentation]    Provision mff on ONT with AR and clients attached. Display resolved AR. Modify AR MAC. Force ARP from client for AR. Display resolved AR. -> AR MAC modified from the old to the new MAC after client ARP.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1422    @subFeature=MAC_Forced_Forwarding    @globalid=2286191    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1422 setup
    [Teardown]   AXOS_E72_PARENT-TC-1422 teardown
    
    Tg Stc Device Transmit Arp    tg1    host1
    wait until keyword succeeds    5min    5s    check_l3_hosts    eutA    vlan=${service_vlan1}    interface=${service_model.subscriber_point1.name}    ip=${service_ip2}    mac=${service_mac2} 
    Tg Stc Modify Device On Port     tg1    host2    service_p1    mac_addr=${service_mac3}  
    Tg Stc Device Transmit Arp    tg1    host1
    wait until keyword succeeds    5min    5    check_l3_hosts    eutA    vlan=${service_vlan1}    interface=${service_model.subscriber_point1.name}    ip=${service_ip2}    mac=${service_mac3} 
    
*** Keywords ***
AXOS_E72_PARENT-TC-1422 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    log    create static hosts
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${service_ip2}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${service_ip2}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}
    Tg Stc Create Device On Port     tg1    host2    service_p1    intf_ip_addr=${service_ip2}    gateway_ip_addr=${subscriber_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${service_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan1}
AXOS_E72_PARENT-TC-1422 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    log    delete devices
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    Tg Stc Delete Device On Port    tg1    host2    subscriber_p1   mac_addr=${service_mac2}
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
