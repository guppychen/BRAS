*** Settings ***
Documentation     Static Subnet Recreate with IP Source Verify: Provision IP Source Verify with a static subnet entry. Generate UDP (500 byte frames) traffic in each direction. Delete the static entry. Re-generate upstream traffic. Recreate static entry. Re-generate upstream traffic. -> Traffic is only forwarded US when static subnet entry is present.
...
...    Note: DSL Downstream traffic will continue to flow when static entry is removed but ONT will stop traffic.  Assumption is that because MACFF is enabled and entry no longer exists the GPON will no longer forward traffic.
...
...    IPSV with only static entries requires MACFF to be enabled.
...
...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Static_Subnet_Recreate_with_IP_Source_Verify
    [Documentation]    Static Subnet Recreate with IP Source Verify: Provision IP Source Verify with a static subnet entry. Generate UDP (500 byte frames) traffic in each direction. Delete the static entry. Re-generate upstream traffic. Recreate static entry. Re-generate upstream traffic. -> Traffic is only forwarded US when static subnet entry is present.
    ...
    ...    Note: DSL Downstream traffic will continue to flow when static entry is removed but ONT will stop traffic.  Assumption is that because MACFF is enabled and entry no longer exists the GPON will no longer forward traffic.
    ...
    ...    IPSV with only static entries requires MACFF to be enabled.
    ...
    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-562    @GlobalID=2286109    @EUT=NGPON2-4
    [Setup]      setup
    check_l3_hosts    eutA    vlan=${service_vlan}    interface=${service_model.subscriber_point1.name}    l3-host=${client_subnet}
    create_raw_traffic_udp    tg1    matchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac1}    mac_src=${client_mac1}    ip_dst=${gateway1}    ip_src=${client_ip1}    ip_src_count=253    ip_src_mode=increment    ip_src_step=0.0.0.1    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list    matchip_up    notmatchip_down
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within    tg1    notmatchip_down    ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    verify_traffic_stream_all_pkt_loss    tg1    matchip_up
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet2}    gateway1 ${gateway2} mask ${mask24}
    create_raw_traffic_udp    tg1    matchip_up_new    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac2}    mac_src=${client_mac2}    ip_dst=${gateway2}    ip_src=${client_ip2}    ip_src_count=253    ip_src_mode=increment    ip_src_step=0.0.0.1    rate_mbps=${rate_mbps1}
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within    tg1    matchip_up_new    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    notmatchip_down    ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    verify_traffic_stream_all_pkt_loss    tg1    matchip_up
    [Teardown]   teardown



*** Keywords ***
setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_subnet}    gateway1 ${gateway1} mask ${mask24}

teardown
    Tg Delete All Traffic    tg1
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}