*** Settings ***
Documentation     Summary:
...               The acronym TLS stands for Transparent LAN Services. TLS allows traffic from multiple customers to be transparently
...               forwarded through an access network using service VLANs or S-VLAN.
...               This is done by wrapping customer vlans (c-vids) with a service vlan (s-vid).
...
...               For the gpon implementation the s-vid is added at the ont. Traffic entering a TLS port on an ont will have an s-vid
...               applied to it. So untagged traffic will enter the pon with a single tag and c-vid untagged traffic that enters the
...               TLS port on the ont will have a Double Q tag (DQ tag).
Resource          ../base.robot


*** Variables ***


*** Test Cases ***
tc_TLAN_Single_tagged_traffic_tlan_between_different_ONTs_on_the_same_gpon_port
    [Documentation]    Summary:
    ...    The acronym TLS stands for Transparent LAN Services. TLS allows traffic from multiple customers to be transparently
    ...    forwarded through an access network using service VLANs or S-VLAN.
    ...    This is done by wrapping customer vlans (c-vids) with a service vlan (s-vid).
    ...
    ...    For the gpon implementation the s-vid is added at the ont. Traffic entering a TLS port on an ont will have an s-vid
    ...    applied to it. So untagged traffic will enter the pon with a single tag and c-vid untagged traffic that enters the
    ...    TLS port on the ont will have a Double Q tag (DQ tag).
    [Tags]       @EUT=NGPON2-4     @TCID=AXOS_E72_PARENT-TC-146    @GlobalID=1526518
    [Setup]      case setup
    log    Send known Unicast frames from each EP frames are received from each EP
    Tg Stc Create Device On Port    tg1    uplink    service_p1    intf_ip_addr=${int_ip1}    gateway_ip_addr=${int_ip2}    mac_addr=${int_mac1}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan}
    Tg Stc Create Device On Port    tg1    downlink    subscriber_p1    intf_ip_addr=${int_ip2}    gateway_ip_addr=${int_ip1}    mac_addr=${int_mac2}    encapsulation=ethernet_ii_vlan    vlan_id=${subscriber_vlan}
    start_capture    tg1    service_p1
    Tg Stc Device Transmit Arp    tg1    uplink
    Tg Stc Device Transmit Arp    tg1    uplink
    Tg Stc Device Transmit Arp    tg1    uplink
    stop_capture    tg1    service_p1
    ${res1}    get_packet_counter_on_port_with_filter    tg1    service_p1    arp and eth.src==${int_mac2}
    should be true    ${res1}>0
    start_capture    tg1    subscriber_p1
    Tg Stc Device Transmit Arp    tg1    downlink
    Tg Stc Device Transmit Arp    tg1    downlink
    Tg Stc Device Transmit Arp    tg1    downlink
    stop_capture    tg1    subscriber_p1
    ${res2}    get_packet_counter_on_port_with_filter    tg1    subscriber_p1    arp and eth.src==${int_mac1}
    should be true    ${res2}>0
    create_bound_traffic_udp    tg1    bound_upstream    subscriber_p1    uplink    downlink    ${rate_mbps1}
    create_bound_traffic_udp    tg1    bound_downstream    service_p1    downlink    uplink    ${rate_mbps1}
    log    Send unknown unicast frames from each EP EUT frames are received from each EP
    TG Create Single Tagged Stream On Port    tg1    ucast1_2    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${mac2}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    TG Create Single Tagged Stream On Port    tg1    ucast2_1    subscriber_p1    service_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${mac1}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    log    Send Bcast from each EP EUT frames are received from each EP
    TG Create Single Tagged Stream On Port    tg1    bcast1_2    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${bcast_mac}    mac_src=${mac3}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    TG Create Single Tagged Stream On Port    tg1    bcast2_1    subscriber_p1    service_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${bcast_mac}    mac_src=${mac4}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    log    Send multicast frames from each EP EUT frames are received from each EP
    TG Create Single Tagged Stream On Port    tg1    mcast1_2    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${mcast_mac1}    mac_src=${mac5}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    TG Create Single Tagged Stream On Port    tg1    mcast2_1    subscriber_p1    service_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    mac_dst=${mcast_mac2}    mac_src=${mac6}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps10000}
    tg start all traffic    tg1
    sleep    10
    tg stop all traffic    tg1
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    tg start all traffic    tg1
    sleep    ${traffic_run_time}
    tg stop all traffic    tg1
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    Tg Verify Traffic Loss Rate For All Streams Is Within    tg1    ${loss_rate1}
    save_and_analyze_packet_on_port    tg1    service_p1    vlan.id==${subscriber_vlan}    ${store_path1}
    save_and_analyze_packet_on_port    tg1    subscriber_p1    vlan.id==${subscriber_vlan}    ${store_path2}
    [Teardown]   case teardown


*** Keywords ***
case setup
    log    Provision TLAN service Provision succeed.
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    mode=ELAN
    log    subscriber_point_l2_basic_svc_provision, single tag service
    &{res}    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan    cfg_prefix=mol
    set suite variable    &{res}    &{res}
    subscriber_point_add_svc_user_defined    subscriber_point2    ${service_vlan}    &{res}[policymap]


case teardown
    Tg Delete All Traffic    tg1
    Tg Stc Delete Device On Port    tg1    uplink    service_p1
    Tg Stc Delete Device On Port    tg1    downlink    subscriber_p1
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${service_vlan}    &{res}[policymap]
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cfg_prefix=mol
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}