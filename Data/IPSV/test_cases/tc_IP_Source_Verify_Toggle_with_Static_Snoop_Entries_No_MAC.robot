*** Settings ***
Documentation     IP Source Verify Toggle with Static Snoop Entries (No MAC): Provision IP Source Verify enabled with a single static snoop entry. Generate UDP (500 byte frames) traffic in the subscriber-to-network  direction for the provisioned snoop entry and from a second static host (no static entry). Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic with source of the host with the static entry is forwarded within 11% of the transmitted rate.  Traffic source by the host without a static entry is only forwarded when IPSV is disabled.  If GPON traffic to/fro the host without a static entry is not forwarded.  If DSL and damac = AR the host without an entry will be forwarded only when IPSV is disabled.
...
...    Note: DSL Downstream traffic will continue to flow when static entry is removed but ONT will stop traffic.  Assumption is that because MACFF is enabled and entry no longer exists the GPON will no longer forward traffic.
...
...    Note: Traffic verification of downstream traffic is tricky.  If the host is not learned generation of non-broadcast traffic will be flooded.

...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_IP_Source_Verify_Toggle_with_Static_Snoop_Entries_No_MAC
    [Documentation]    IP Source Verify Toggle with Static Snoop Entries (No MAC): Provision IP Source Verify enabled with a single static snoop entry. Generate UDP (500 byte frames) traffic in the subscriber-to-network  direction for the provisioned snoop entry and from a second static host (no static entry). Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic with source of the host with the static entry is forwarded within 11% of the transmitted rate.  Traffic source by the host without a static entry is only forwarded when IPSV is disabled.  If GPON traffic to/fro the host without a static entry is not forwarded.  If DSL and damac = AR the host without an entry will be forwarded only when IPSV is disabled.
    ...
    ...    Note: DSL Downstream traffic will continue to flow when static entry is removed but ONT will stop traffic.  Assumption is that because MACFF is enabled and entry no longer exists the GPON will no longer forward traffic.
    ...
    ...    Note: Traffic verification of downstream traffic is tricky.  If the host is not learned generation of non-broadcast traffic will be flooded.

    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    ...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-569    @GlobalID=2286116    @EUT=NGPON2-4
    [Setup]      setup
    Tg Stc Create Device On Port    tg1    uplink    service_p1    intf_ip_addr=${gateway1}    gateway_ip_addr=${client_ip1}    mac_addr=${service_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${service_vlan}
    Tg Stc Create Device On Port    tg1    downlink    subscriber_p1    intf_ip_addr=${client_ip1}    gateway_ip_addr=${gateway1}    mac_addr=${client_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan}
    start_capture    tg1    service_p1
    Tg Stc Device Transmit Arp    tg1    uplink
    stop_capture    tg1    service_p1
    ${res1}    get_packet_counter_on_port_with_filter    tg1    service_p1    arp and eth.src==${client_mac1}      ${pcapfile}
    should be true    ${res1}>0
    start_capture    tg1    subscriber_p1
    Tg Stc Device Transmit Arp    tg1    downlink
    stop_capture    tg1    subscriber_p1
    ${res2}    get_packet_counter_on_port_with_filter    tg1    subscriber_p1    arp and eth.src==${service_mac1}     ${pcapfile}
    should be true    ${res2}>0
    log    show dhcp leases, 1
    check_l3_hosts    eutA    vlan=${service_vlan}    interface=${service_model.subscriber_point1.name}    l3-host=${gateway1}
    create_bound_traffic_udp    tg1    bound_upstream    subscriber_p1    uplink    downlink    ${rate_mbps1}
    create_bound_traffic_udp    tg1    bound_downstream    service_p1    downlink    uplink    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  bound_upstream    bound_downstream    notmatchip_down
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
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    gateway1 ${gateway1}
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