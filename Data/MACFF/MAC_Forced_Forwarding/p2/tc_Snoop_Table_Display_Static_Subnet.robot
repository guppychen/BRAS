*** Settings ***
Documentation     Provision service with mff & DHCP Snoop enabled.  Provision a static subnet entry.  Display snoop table.  Learn a subnet host MAC via an ARP from the host to the upstream gateway.  Display snoop table. -> Static host entries are displayed in the snoop table when provisioned and learned.

Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_Snoop_Table_Display_Static_Subnet
    [Documentation]    Provision service with mff & DHCP Snoop enabled.  Provision a static subnet entry.  Display snoop table.  Learn a subnet host MAC via an ARP from the host to the upstream gateway.  Display snoop table. -> Static host entries are displayed in the snoop table when provisioned and learned.
    
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1411    @subFeature=MAC_Forced_Forwarding    @globalid=2286180    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1411 setup
    [Teardown]   AXOS_E72_PARENT-TC-1411 teardown
    
    log    check snoop table
    ${res}    cli    eutA    show l3-hosts
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip1}(.*)up-down-state
    Log    ${grp1}
    log     verify AR info
    should match regexp    ${grp1}    mac\\s+00:00:00:00:00:00
    log     verify static subnet info
    ${match}    ${grp2}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${network_ip1}(.*)up-down-state
    should match regexp    ${grp2}    gateway1\\s+${gateway_ip1}
    should match regexp    ${grp2}    mac\\s+00:00:00:00:00:00
    should match regexp    ${grp2}    mask\\s+${mask_ip1}
    Tg Stc Device Transmit Arp    tg1    host1
    wait until keyword succeeds    5min    10s    check_l3_hosts    eutA    0    ${service_vlan1}    gateway1=${gateway_ip1}    l3-host=${gateway_ip1}    mac=${gateway_mac1} 
    log    check snoop table
    ${res}    cli    eutA    show l3-hosts
    ${match}    ${grp1}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${gateway_ip1}(.*)up-down-state
    Log    ${grp1}
    log     verify AR info
    should match regexp    ${grp1}    mac\\s+${gateway_mac1}
    should match regexp    ${grp1}    interface\\s+${service_model.service_point2.member.interface1}
    log     verify static host info
    ${match}    ${grp2}    should match regexp    ${res}    (?s)l3-host\\s+${service_vlan1}\\s+${subscriber_ip1}(.*)up-down-state
    should match regexp    ${grp2}    mac\\s+${subscriber_mac1}
    should match regexp    ${grp2}    gateway1\\s+${gateway_ip1}

*** Keywords ***
AXOS_E72_PARENT-TC-1411 setup
    [Documentation]  setup
    [Arguments]
    log    setup

    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    log    create static host/subnet
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${network_ip1}    gateway1 ${gateway_ip1} mask ${mask_ip1}
    log    create devices
    Tg Stc Create Device On Port     tg1    host1    subscriber_p1    intf_ip_addr=${subscriber_ip1}    gateway_ip_addr=${gateway_ip1}    resolve_gateway_mac=true
    ...                         enable_ping_response=1     mac_addr=${subscriber_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan1}

    
AXOS_E72_PARENT-TC-1411 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    log    delete devices
    Tg Stc Delete Device On Port    tg1    host1    subscriber_p1   mac_addr=${subscriber_mac1}
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static host/subnet
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
