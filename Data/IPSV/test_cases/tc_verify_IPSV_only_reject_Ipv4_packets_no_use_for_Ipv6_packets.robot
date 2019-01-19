*** Settings ***
Documentation     1	Enable Ip-source-verify on the DUT port which is connected to STC A . Disable MACFF and DHCP snooping 	Verify IPSV is properly Provisioned.
...    2	Configure a static association with a valid ip and mac address 	Config should be accepted
...    3	Provision unicast bound streams. Transmit bidirectional traffic. 	Verify that bidirectional goes through the DUT fine.
...    4	Now Provision a unicast raw ipv6 upstream and downstream, with not matched source IP and source MAC. Transmit bidirectional traffic. 	Verify that bidirectional goes through the DUT fine.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_verify_IPSV_only_reject_Ipv4_packets_no_use_for_Ipv6_packets
    [Documentation]    1	Enable Ip-source-verify on the DUT port which is connected to STC A . Disable MACFF and DHCP snooping 	Verify IPSV is properly Provisioned.
    ...    2	Configure a static association with a valid ip and mac address 	Config should be accepted
    ...    3	Provision unicast bound streams. Transmit bidirectional traffic. 	Verify that bidirectional goes through the DUT fine.
    ...    4	Now Provision a unicast raw ipv6 upstream and downstream, with not matched source IP and source MAC. Transmit bidirectional traffic. 	Verify that bidirectional goes through the DUT fine.
    [Tags]       @TCID=AXOS_E72_PARENT-TC-594    @GlobalID=2286141    @EUT=NGPON2-4
    [Setup]      case setup
    log    create 3 streams, match ipv4 up, notmatch ipv4 up, ipv6 stream, verify that not match ipv4 upstream loss 100%, matched ipv4 upstream and ipv6 stream pass 100%
    create_raw_traffic_udp    tg1    matchdown    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${client_mac1}    mac_src=${service_mac1}    ip_dst=${client_ip1}    ip_src=${gateway1}    rate_mbps=${rate_mbps1}

    create_raw_traffic_udp    tg1    matchup    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac1}    mac_src=${client_mac1}    ip_dst=${gateway1}    ip_src=${client_ip1}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchup    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac2}    mac_src=${client_mac2}    ip_dst=${gateway2}    ip_src=${client_ip2}    rate_mbps=${rate_mbps1}
    TG Create Single Tagged Stream On Port    tg1    ipv6up    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed
     ...    mac_src=${dclient_mac}    mac_dst=${dserver_mac}    l3_protocol=ipv6    ipv6_src_addr=${ipv61}    ipv6_dst_addr=${ipv62}    l4_protocol=udp    rate_pps=${rate_pps1}
     ...    udp_dst_port=64    udp_src_port=63
    Tg start Arp nd on all devices     tg1
    Tg start arp nd on all stream blocks    tg1
    sleep    2s
    Tg Start All Traffic    tg1
    sleep    10
    tg save config into file   tg1    /tmp/ipsv_ipv6.xml
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    log    let's clear the traffic path
    cli     eutA         clear interface ethernet ${service_model.service_point1.member.interface1} counters
    cli     eutA         clear interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         clear interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counter

    log    let's show the traffic path

    cli     eutA         show interface ethernet ${service_model.service_point1.member.interface1} counters
    cli     eutA         show interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counter
    sleep     30

    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5


    log    let's show the traffic path
    cli     eutA         show interface ethernet ${service_model.service_point1.member.interface1} counters
    cli     eutA         show interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counter


    verify_traffic_stream_all_pkt_loss    tg1    notmatchup
    Tg Verify Traffic Loss For Stream Is Within    tg1    matchup    ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    ipv6up    ${loss_rate}
    [Teardown]   case teardown


*** Keywords ***
case setup
    log    STEP:1 Enable Ip-source-verify on the DUT port which is connected to STC A . Disable MACFF and DHCP snooping Verify IPSV is properly Provisioned.
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    log    STEP:2 Configure a static association with a valid ip and mac address Config should be accepted
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    gateway1 ${gateway1} mac ${client_mac1}

case teardown
    Tg Delete All Traffic    tg1
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}