*** Settings ***
Documentation     Static Subnet with IP Source Verify Toggle: Provision IP Source Verify with a static subnet entry. Generate UDP (500 byte frames) traffic in each direction. Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic is forwarded within 11% of the transmitted rate.
...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Static_Subnet_with_IP_Source_Verify_Toggle
    [Documentation]    Static Subnet with IP Source Verify Toggle: Provision IP Source Verify with a static subnet entry. Generate UDP (500 byte frames) traffic in each direction. Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic is forwarded within 11% of the transmitted rate.
    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    ...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-561    @GlobalID=2286108    @EUT=NGPON2-4
    [Setup]      setup
    Tg Stc Create Device On Port    tg1    uplink    service_p1    intf_ip_addr=${gateway1}    gateway_ip_addr=${client_ip1}    mac_addr=${service_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan}
    Tg Stc Create Device On Port    tg1    downlink    subscriber_p1    intf_ip_addr=${client_ip1}    gateway_ip_addr=${gateway1}    mac_addr=${client_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan}
    Tg Stc Device Transmit Arp    tg1    downlink
    log    show dhcp leases, 1
    ${res}    cli    eutA     show l3|tab
    should match regexp    ${res}    ${service_vlan}\\s+${client_ip1}\\s+-\\s+${service_model.subscriber_point1.name}\\s+-\\s+${client_mac1}\\s+-\\s+${gateway1}
    should match regexp    ${res}    ${service_vlan}\\s+${gateway1}\\s+-\\s+${service_model.service_point1.member.interface1}\\s+-\\s+${service_mac1}
    create_bound_traffic_udp    tg1    upstream    subscriber_p1    uplink    downlink    ${rate_mbps1}
    create_bound_traffic_udp    tg1    downstream    service_p1    downlink    uplink    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  upstream    downstream    notmatchip_down
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled    mff=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    [Teardown]   teardown




*** Keywords ***
setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled    mff=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet}    gateway1 ${gateway1} mask ${mask24}

teardown
    Tg Delete All Traffic    tg1
    Tg Stc Delete Device On Port    tg1    uplink    service_p1
    Tg Stc Delete Device On Port    tg1    downlink    subscriber_p1
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}