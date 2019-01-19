*** Settings ***
Documentation     Multiple VLAN Registration Protocol (MVRP)
Resource          ../base.robot


*** Variables ***
${mvrp_mac1}    01:80:C2:00:00:21
${mvrp_mac2}    01:80:C2:00:00:0D


*** Test Cases ***
tc_TLAN_L2CP_Forward_Multiple_VLAN_Registration_Protocol_MVRP
    [Documentation]    1	Send MVRP
    ...    2	Ethertype: 0x88F5
    ...    3	Dest MAC
    ...    4	01-80-C2-00-00-21
    ...    5	01-80-C2-00-00-0D
    [Tags]       @EUT=NGPON2-4     @TCID=AXOS_E72_PARENT-TC-164    @GlobalID=1584214   @ticket=PREM-23066
    [Setup]      case setup
    TG Create Untagged Stream On Port    tg1    mac11_2    service_p1    subscriber_p1    mac_dst=${mvrp_mac1}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=88F5
    TG Create Untagged Stream On Port    tg1    mac12_1    subscriber_p1    service_p1    mac_dst=${mvrp_mac1}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=88F5
    TG Create Untagged Stream On Port    tg1    mac21_2    service_p1    subscriber_p1    mac_dst=${mvrp_mac2}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=88F5
    TG Create Untagged Stream On Port    tg1    mac22_1    subscriber_p1    service_p1    mac_dst=${mvrp_mac2}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=88F5
    tg start all traffic    tg1
    sleep    10
    tg stop all traffic    tg1
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1

    cli     eutA         clear interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         show interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         clear interface pon ${service_model.subscriber_point2.attribute.pon_port} counters
    cli     eutA         show interface pon ${service_model.subscriber_point2.attribute.pon_port} counters

    cli     eutA         clear interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counters
    cli     eutA         clear interface ont-ethernet ${service_model.subscriber_point2.member.interface1} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point2.member.interface1} counters

    tg start all traffic    tg1
    sleep    ${traffic_run_time}
    tg stop all traffic    tg1
    sleep    5
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1

    cli     eutA         show interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         show interface pon ${service_model.subscriber_point2.attribute.pon_port} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point2.member.interface1} counters

    Tg Verify No Traffic Loss For All Streams    tg1
    save_and_analyze_packet_on_port    tg1    service_p1    mrp-mvrp    ${store_path1}
    save_and_analyze_packet_on_port    tg1    subscriber_p1    mrp-mvrp    ${store_path2}
    [Teardown]   case teardown



*** Keywords ***
case setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    mode=ELAN
    log    subscriber_point_l2_basic_svc_provision
    &{res}    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}    cfg_prefix=mol
    set suite variable    &{res}    &{res}
    subscriber_point_add_svc_user_defined    subscriber_point3    ${service_vlan}    &{res}[policymap]


case teardown
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc_user_defined    subscriber_point3    ${service_vlan}    &{res}[policymap]
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}    cfg_prefix=mol
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}