*** Settings ***
Documentation     1	Enable Ip-source-verify and DHCP snooping on vlan . Disable MACFF. 	Verify that DHCP Snooping and IPSV are properly Provisioned.
...    2	provision dhcp server and client on IXIA. start protocol.	verify that lease is generated both on IXIA and EUT
...    3	provision bidirectional unicast bound streams and raw traffic with not matched source IP and mac.	verify that bidirectional bound traffics go fine. raw traffics with not matched source IP and MAC only downstream goes fine and upstream fully lossed.
...    4	save config and reboot system	provision accepted
...    5	wait for card ready	verify that all streams perform like before
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_verify_IPSV_work_after_reboot_system
    [Documentation]    1	Enable Ip-source-verify and DHCP snooping on vlan . Disable MACFF. 	Verify that DHCP Snooping and IPSV are properly Provisioned.
    ...    2	provision dhcp server and client on IXIA. start protocol.	verify that lease is generated both on IXIA and EUT
    ...    3	provision bidirectional unicast bound streams and raw traffic with not matched source IP and mac.	verify that bidirectional bound traffics go fine. raw traffics with not matched source IP and MAC only downstream goes fine and upstream fully lossed.
    ...    4	save config and reboot system	provision accepted
    ...    5	wait for card ready	verify that all streams perform like before
    [Tags]       @TCID=AXOS_E72_PARENT-TC-595    @GlobalID=2286142    @EUT=NGPON2-4
    [Setup]      case setup
    log    STEP:2 provision dhcp server and client on IXIA. start protocol. verify that lease is generated both on IXIA and EUT
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}    lease_time=38400
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}    session=5
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 5
    check_l3_hosts    eutA    5    ${service_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:3 provision bidirectional unicast bound streams and raw traffic with not matched source IP and mac. verify that bidirectional bound traffics go fine. raw traffics with not matched source IP and MAC only downstream goes fine and upstream fully lossed.
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    20
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
    log    STEP:4 save config and reboot system provision accepted
    Reload System    eutA
    sleep    20s
    log    STEP:5 wait for card ready verify that all streams perform like before
    log    show dhcp leases, 5
    check_l3_hosts    eutA    5    ${service_vlan}    ${service_model.subscriber_point1.name}
    # added by llin 2018.1.30
    subscriber_point_check_status_up	    subscriber_point1
    # added by llin 2018.1.30
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    [Teardown]   case teardown


*** Keywords ***
case setup
    log    STEP:1 Enable Ip-source-verify and DHCP snooping on vlan . Disable MACFF. Verify that DHCP Snooping and IPSV are properly Provisioned.
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan with ipsv enabled, mff disabled
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}    source-verify=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


case teardown
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
    # modified by llin for AT-3559 start
    ${res}    cli   eutA    copy running-config startup-config    timeout=10
    should contain    ${res}    Copy completed
    # # modified by llin for AT-3559 end