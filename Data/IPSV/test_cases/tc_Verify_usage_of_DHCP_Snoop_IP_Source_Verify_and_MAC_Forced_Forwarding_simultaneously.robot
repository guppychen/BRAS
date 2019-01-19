*** Settings ***
Documentation     Calix Platforms must support the usage of DHCP Snoop, IP Source Verify, and MAC Forced Forwarding simultaneously.
...               This configuration enables all of the Access Interface security features, providing the highest level of security for the Access Network.
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_Verify_usage_of_DHCP_Snoop_IP_Source_Verify_and_MAC_Forced_Forwarding_simultaneously
    [Documentation]    Calix Platforms must support the usage of DHCP Snoop, IP Source Verify, and MAC Forced Forwarding simultaneously.
    ...    This configuration enables all of the Access Interface security features, providing the highest level of security for the Access Network.
    [Tags]    @TCID=AXOS_E72_PARENT-TC-593    @GlobalID=2286140    @EUT=NGPON2-4
    [Setup]    setup
    log    STEP:Calix Platforms must support the usage of DHCP Snoop, IP Source Verify, and MAC Forced Forwarding simultaneously.
    log    STEP:This configuration enables all of the Access Interface security features, providing the highest level of security for the Access Network.
    log    create DHCP server and client on STC
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}
    log    create bidirectional bound traffic, up and down raw streams with not matched source ip and mac
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    ${rate_mbps1}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    log    check all traffic can pass without ipsv config
    Tg Start All Traffic     tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    log    verify no traffic loss of 4 stream
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    log    enable ipsv
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    log    verify raw downstream goes fine, and raw upstream loss 100%. 2 bound streams no loss.
    Tg Verify Traffic Loss For Stream Is Within    tg1    dhcp_upstream     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    dhcp_downstream    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    notmatchip_down    ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    log    enable mff
    prov_vlan    eutA    ${service_vlan}    mff=enabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    log    verify raw downstream goes fine, and raw upstream loss 100%. 2 bound streams no loss.
    Tg Verify Traffic Loss For Stream Is Within    tg1    dhcp_upstream    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    dhcp_downstream    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    notmatchip_down    ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    log    disable ipsv and mff, verify all streams no loss
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled    mff=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    log    setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
teardown
    log    teardown
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Control Dhcp Server    tg1    dserver    stop
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_profile_name}
