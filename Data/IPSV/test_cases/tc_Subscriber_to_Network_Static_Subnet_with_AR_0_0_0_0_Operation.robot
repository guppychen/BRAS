*** Settings ***
Documentation     Subscriber-to-Network Static Subnet with AR 0.0.0.0 Operation: Provision static subnet with no GW. IPSV is enabled. Generate UDP traffic from a subnet subscriber to an unlearned endpoint on the same subnet.  Disable IPSV. Re-generate traffic. Enable IPSV. Re-generate traffic. -> No traffic is forwarded.
...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_to_Network_Static_Subnet_with_AR_0_0_0_0_Operation
    [Documentation]    Subscriber-to-Network Static Subnet with AR 0.0.0.0 Operation: Provision static subnet with no GW. IPSV is enabled. Generate UDP traffic from a subnet subscriber to an unlearned endpoint on the same subnet.  Disable IPSV. Re-generate traffic. Enable IPSV. Re-generate traffic. -> No traffic is forwarded.

    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-587    @GlobalID=2286134    @EUT=NGPON2-4
    [Setup]      case setup
    log    provision device on server and client port, start arp
    Tg Stc Create Device On Port    tg1    uplink    service_p1    intf_ip_addr=${gateway1}    gateway_ip_addr=${client_ip1}    mac_addr=${service_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan}
    Tg Stc Create Device On Port    tg1    downlink    subscriber_p1    intf_ip_addr=${client_ip1}    gateway_ip_addr=${gateway1}    mac_addr=${client_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan}
    Tg Stc Device Transmit Arp    tg1    uplink
    Tg Stc Device Transmit Arp    tg1    downlink
    log    server can learn client mac, but client cannot learn server mac, lease no gateway
    ${res}    cli    eutA    show l3|tab
    should match regexp    ${res}    ${service_vlan}\\s+${client_subnet}\\s+${mask24}\\s+${service_model.subscriber_point1.name}\\s+-\\s+${mac0}
    should match regexp    ${res}    ${service_vlan}\\s+${client_ip1}\\s+-\\s+${service_model.subscriber_point1.name}\\s+-\\s+${client_mac1}
    log    create bound traffic, upstream loss 100%, and downstream no loss
    create_bound_traffic_udp    tg1    upstream    subscriber_p1    uplink    downlink    ${rate_mbps1}
    create_bound_traffic_udp    tg1    downstream    service_p1    downlink    uplink    ${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    verify_traffic_stream_all_pkt_loss    tg1    upstream
    Tg Verify Traffic Loss For Stream Is Within     tg1    downstream     ${loss_rate}
    log    disable ipsv, upstream loss 100%, and downstream no loss
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    verify_traffic_stream_all_pkt_loss    tg1    upstream
    Tg Verify Traffic Loss For Stream Is Within     tg1    downstream     ${loss_rate}
    [Teardown]   case teardown



*** Keywords ***
case setup
    log    STEP:Subscriber-to-Network Static Subnet with AR 0.0.0.0 Operation: Provision static subnet with no GW. IPSV is enabled. Generate UDP traffic from a subnet subscriber to an unlearned endpoint on the same subnet. Disable IPSV. Re-generate traffic. Enable IPSV. Re-generate traffic. -> No traffic is forwarded.
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled    mff=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    log    create sub-net with gateway 0.0.0.0
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet}    gateway1 ${gateway0} mask ${mask24}

case teardown
    Tg Delete All Traffic    tg1
    Tg Stc Delete Device On Port    tg1    uplink    service_p1
    Tg Stc Delete Device On Port    tg1    downlink    subscriber_p1
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}