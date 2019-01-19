*** Settings ***
Documentation     1	dhcp snoop enabled, macff enabled, ipsv enabled on service vlan.	Verify that MACFF, DHCP Snooping and IPSV are properly Provisioned.
...    2	provision dhcp server and client on IXIA. start protocol.	negociate success on ixia, and can show lease table on EUT
...    3	create bidirectional unicast bound streams. and bidirectional unicast raw streams with not matched source ip and mac	verify bound streams and raw down stream no loss, and raw upstreams fully lossed.
...    4	remove eth-svc from ont-port	verify no dhcp lease on EUT and all streams loss 100%
...    5	re-add eth-svc on ont-port	verify dhcp lease recover. all streams recover and perform like before
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_verify_IPSV_can_re_work_after_delete_and_re_add_eth_service_from_ont_port
    [Documentation]    1	dhcp snoop enabled, macff enabled, ipsv enabled on service vlan.	Verify that MACFF, DHCP Snooping and IPSV are properly Provisioned.
    ...    2	provision dhcp server and client on IXIA. start protocol.	negociate success on ixia, and can show lease table on EUT
    ...    3	create bidirectional unicast bound streams. and bidirectional unicast raw streams with not matched source ip and mac	verify bound streams and raw down stream no loss, and raw upstreams fully lossed.
    ...    4	remove eth-svc from ont-port	verify no dhcp lease on EUT and all streams loss 100%
    ...    5	re-add eth-svc on ont-port	verify dhcp lease recover. all streams recover and perform like before
    [Tags]       @TCID=AXOS_E72_PARENT-TC-596    @GlobalID=2286143    @EUT=NGPON2-4
    [Setup]      setup
    log    STEP:2 provision dhcp server and client on IXIA. start protocol. negociate success on ixia, and can show lease table on EUT
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}    session=5
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 5
    check_l3_hosts    eutA    5    ${service_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:3 create bidirectional unicast bound streams. and bidirectional unicast raw streams with not matched source ip and mac verify bound streams and raw down stream no loss, and raw upstreams fully lossed.
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    ${rate_mbps1}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    Tg Save Config Into File    tg1     /tmp/stream.xml
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
    log    STEP:4 remove eth-svc from ont-port verify no dhcp lease on EUT and all streams loss 100%
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    show dhcp leases, 0
    check_l3_hosts    eutA    0
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    verify_no_traffic_on_port_with_filter    tg1    service_p1    udp and vlan.id==${service_vlan}
    verify_no_traffic_on_port_with_filter    tg1    subscriber_p1    ip.src==${dserver_ip} and ip.src==${dip}
    log    STEP:5 re-add eth-svc on ont-port verify dhcp lease recover. all streams recover and perform like before
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 5
    check_l3_hosts    eutA    5    ${service_vlan}    ${service_model.subscriber_point1.name}
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
    log    STEP:1 dhcp snoop enabled, macff enabled, ipsv enabled on service vlan. Verify that MACFF, DHCP Snooping and IPSV are properly Provisioned.
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan with ipsv enabled, mff enabled
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}    source-verify=enabled    mff=enabled
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