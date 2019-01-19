*** Settings ***
Documentation     DHCPv4 Snoop Agent must support static provisioning of DHCP entries (IP to MAC mappings) on all ONT Ethernet ports
...
...    Such entries can be created by actually building a static lease entry,or by specifying a static host entry (with MAC) and importing it into the lease database. The key is that the static address not be allocated by the DHCP server (such should be flagged).
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCPv4_Snoop_Agent_must_support_static_provisioning_of_DHCP_entries_IP_to_MAC_mappings_on_all_ONT_Ethernet_ports
    [Documentation]    1	create static dhcp entry on ont port	success
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-703    @globalid=2307043    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 create static dhcp entry on ont port success
    log    run traffic and check static dhcp entry
    create_raw_traffic_udp    tg1    matchip_up    service_p1    subscriber_p1    mac_dst=${server_mac}    mac_src=${client_mac}    ip_dst=${server_ip}    ip_src=${lease_start}    rate_mbps=10
    create_raw_traffic_udp    tg1    matchip_down    subscriber_p1    service_p1    ovlan=${stag_vlan}    mac_dst=${client_mac}    mac_src=${server_mac}    ip_dst=${lease_start}    ip_src=${server_ip}    rate_mbps=10
    check_l3_hosts    eutA    0    vlan=${stag_vlan}    interface=${service_model.subscriber_point1.name}    l3-host=${lease_start}    host-type=provisioned
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${STC_wait_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${stag_vlan}    ${lease_start}    gateway1 ${server_ip} mac ${client_mac}


case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${stag_vlan}
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}