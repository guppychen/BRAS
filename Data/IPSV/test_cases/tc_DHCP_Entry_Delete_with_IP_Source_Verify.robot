*** Settings ***
Documentation     DHCP Entry Delete with IP Source Verify: Provision IP Source Verify and DHCP Snooping enabled. Force a client to obtain a DHCP address. Generate UDP (500 byte frames) traffic in each direction. Delete IP address from system. Re-generate traffic. Renew IP address. Force the lease to renew. Re-generate traffic. -> Upstream traffic is only forwarded US when host entry is present.  Downstream direction is forwarded throughout the test.  Downstream traffic when DHCP snoop disabled would not be allowed after the ARP entry has timed out but that is not the focus of this test.
...
...    SR Security Feature Interaction Config #12: DHCP, DHCP Snoop Enabled, MACFF Disabled, IPSV Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Entry_Delete_with_IP_Source_Verify
    [Documentation]    DHCP Entry Delete with IP Source Verify: Provision IP Source Verify and DHCP Snooping enabled. Force a client to obtain a DHCP address. Generate UDP (500 byte frames) traffic in each direction. Delete IP address from system. Re-generate traffic. Renew IP address. Force the lease to renew. Re-generate traffic. -> Upstream traffic is only forwarded US when host entry is present.  Downstream direction is forwarded throughout the test.  Downstream traffic when DHCP snoop disabled would not be allowed after the ARP entry has timed out but that is not the focus of this test.
    ...
    ...    SR Security Feature Interaction Config #12: DHCP, DHCP Snoop Enabled, MACFF Disabled, IPSV Enabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-566     @GlobalID=2286113    @EUT=NGPON2-4
    [Setup]      setup
    log    create dhcp server and client, can see 1 dhcp lease
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}
    log    create bi-directional bound traffic and not match traffic, only matched upstream and all downstream can pass, not matched downstream loss 100%
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    ${rate_mbps1}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  dhcp_upstream    dhcp_downstream    notmatchip_down

    tg save config into file  tg1   /tmp/ipsv.xml
    
    Tg Start Arp Nd On All Stream Blocks  tg1 
    Tg Start All Traffic    tg1
    sleep    5
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start Arp Nd On All Stream Blocks  tg1 
    Tg Start All Traffic    tg1
    sleep    5
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    log    delete dhcp lease, all upstreams loss 100%

    delete_dhcp_lease    eutA    ${service_vlan}    ${dclient_ip}
    check_l3_hosts    eutA    0
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
#    sleep    ${traffic_run_time}
    sleep    5
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within    tg1    notmatchip_down    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    dhcp_downstream    ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    dhcp_upstream
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    log    restart dhcp client, wait lease created again, all streams perform as before
    Tg Control Dhcp Client    tg1    dcg    start
    wait until keyword succeeds    2min    10s    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}
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
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}    source-verify=enabled    mff=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan

teardown
    run keyword and ignore error  check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}
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