*** Settings ***
Documentation     IP Source Verify Toggle with Static Snoop Entries: Provision IP Source Verify enabled with a single static snoop entry. Generate UDP (500 byte frames) traffic in each direction for the provisioned snoop entry.  Generate the same traffic using a second static host (no static entry). Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic with destination/source of the host with the static entry is forwarded within 11% of the transmitted rate.  If GPON traffic to/fro the host without a static entry is not forwarded.  If DSL and damac = AR the host without an entry will be forwarded only when IPSV is disabled.
...
...    IPSV with only static entries requires MACFF to be enabled.
...
...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
...
...    Note: Other test exist to verify IP Source mismatch forwarding.
...    Note: Not sure why the DSL act differently than GPON.  I sway toward DSL being correct.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_IP_Source_Verify_Toggle_with_Static_Snoop_Entries
    [Documentation]    IP Source Verify Toggle with Static Snoop Entries: Provision IP Source Verify enabled with a single static snoop entry. Generate UDP (500 byte frames) traffic in each direction for the provisioned snoop entry.  Generate the same traffic using a second static host (no static entry). Toggle IP Source Verify to disable. Re-generate traffic. Toggle to enable. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic with destination/source of the host with the static entry is forwarded within 11% of the transmitted rate.  If GPON traffic to/fro the host without a static entry is not forwarded.  If DSL and damac = AR the host without an entry will be forwarded only when IPSV is disabled.
    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    ...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-559    @GlobalID=2286106    @EUT=NGPON2-4
    [Setup]      setup
    log    show lease, static
    check_l3_hosts    eutA    vlan=${service_vlan}    interface=${service_model.subscriber_point1.name}    l3-host=${client_ip1}
    log    create match and unmatch bidirectional traffic, all down stream and matched upstream no loss, not matched upstream loss 100%
    create_raw_traffic_udp    tg1    matchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac1}    mac_src=${client_mac1}    ip_dst=${gateway1}    ip_src=${client_ip1}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    matchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${client_mac1}    mac_src=${service_mac1}    ip_dst=${client_ip1}    ip_src=${gateway1}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  matchip_up    matchip_down    notmatchip_down
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
    log    disabled ipsv, all traffic pass
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    log    enable ipsv again, all streams perform as before
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
    log    create vlan, enable ipsv
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision, change tag
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    log    create static host with mac
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    gateway1 ${gateway1} mac ${client_mac1}


teardown
    Tg Delete All Traffic    tg1
    log    delete all ipv4 l2host on sub-port
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    log    remove eth-svc on sub-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}