*** Settings ***
Documentation     IPSV with Subscriber DHCP Address Change: Provision a service to an access interface with a DHCP Snoop, MACFF, IPSV enabled. Force a subscriber to obtain an IP address with a relatively short lease (5 min). Display AR and lease information. Verify bi-directional traffic between subscriber and a core-network-device.  Force the DHCP Server to offer an address to the subscriber at the renew from a different DHCP pool in a different subnet than the original. Display AR and lease information. Verify bi-directional traffic between subscriber and core-network-device using newly obtain IP. -> Initially the DHCP display matches the address obtained by the server and traffic is forwarded bi-directionally.  After a new address is obtained the display no longer shows the original addressing and the new address is displayed.  Bi-directional traffic using the newly obtained IP address is forwarded.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_IPSV_with_Subscriber_DHCP_Address_Change
    [Documentation]    IPSV with Subscriber DHCP Address Change: Provision a service to an access interface with a DHCP Snoop, MACFF, IPSV enabled. Force a subscriber to obtain an IP address with a relatively short lease (5 min). Display AR and lease information. Verify bi-directional traffic between subscriber and a core-network-device.  Force the DHCP Server to offer an address to the subscriber at the renew from a different DHCP pool in a different subnet than the original. Display AR and lease information. Verify bi-directional traffic between subscriber and core-network-device using newly obtain IP. -> Initially the DHCP display matches the address obtained by the server and traffic is forwarded bi-directionally.  After a new address is obtained the display no longer shows the original addressing and the new address is displayed.  Bi-directional traffic using the newly obtained IP address is forwarded.
    [Tags]       @TCID=AXOS_E72_PARENT-TC-574    @GlobalID=2286121    @EUT=NGPON2-4
    log    STEP:IPSV with Subscriber DHCP Address Change: Provision a service to an access interface with a DHCP Snoop, MACFF, IPSV enabled. Force a subscriber to obtain an IP address with a relatively short lease (5 min). Display AR and lease information. Verify bi-directional traffic between subscriber and a core-network-device. Force the DHCP Server to offer an address to the subscriber at the renew from a different DHCP pool in a different subnet than the original. Display AR and lease information. Verify bi-directional traffic between subscriber and core-network-device using newly obtain IP. -> Initially the DHCP display matches the address obtained by the server and traffic is forwarded bi-directionally. After a new address is obtained the display no longer shows the original addressing and the new address is displayed. Bi-directional traffic using the newly obtained IP address is forwarded.
    [Setup]      setup
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}    l3-host=${dclient_ip}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    ${rate_mbps1}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  dhcp_upstream    dhcp_downstream    notmatchip_down
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
    Tg Modify Dhcp Server    tg1    dserver    ip_address=${dserver_ip2}    ip_gateway=${dserver_ip2}    ipaddress_pool=${dclient_ip2}
    Tg Save Config Into File    tg1     /tmp/stream.xml
    Tg Control Dhcp Server    tg1    dserver    stop
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Control Dhcp Client    tg1    dcg    start
    wait until keyword succeeds    2min    10s    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}    l3-host=${dclient_ip2}
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    stop_capture    tg1    service_p1
    get_packet_counter_on_port_with_filter    tg1    service_p1    ip.src==${dclient_ip2}    ${pcapfile}
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up

    [Teardown]   teardown


*** Keywords ***
setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}    source-verify=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan

teardown
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