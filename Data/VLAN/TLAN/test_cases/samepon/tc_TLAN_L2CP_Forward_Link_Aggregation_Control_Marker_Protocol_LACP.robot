*** Settings ***
Documentation     TLAN: L2CP Forward: Link Aggregation Control/Marker Protocol (LACP)
Resource          ../base.robot


*** Variables ***
${lacp_mac1}    01:80:C2:00:00:00
${lacp_mac2}    01:80:C2:00:00:02
${lacp_mac3}    01:80:C2:00:00:03


*** Test Cases ***
tc_TLAN_L2CP_Forward_Link_Aggregation_Control_Marker_Protocol_LACP
    [Documentation]    1	Send Link Aggregation Control/Marker Protocol (LACP)
    ...    2	Ethertype: 0x8809 Subtypes: 0x01, 0x02
    ...    3	Dest MAC
    ...    4	01-80-C2-00-00-00
    ...    5	01-80-C2-00-00-02
    ...    6	01-80-C2-00-00-03
    ...    7	Check STC at egress	L2CP packet is forwarded
    [Tags]       @EUT=NGPON2-4     @TCID=AXOS_E72_PARENT-TC-149    @GlobalID=1584140     @ticket=PREM-23066
    [Setup]      case setup
    TG Create Untagged Stream On Port    tg1    mac11_2    service_p1    subscriber_p1    mac_dst=${lacp_mac1}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac12_1    subscriber_p1    service_p1    mac_dst=${lacp_mac1}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac21_2    service_p1    subscriber_p1    mac_dst=${lacp_mac2}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac22_1    subscriber_p1    service_p1    mac_dst=${lacp_mac2}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac31_2    service_p1    subscriber_p1    mac_dst=${lacp_mac3}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac32_1    subscriber_p1    service_p1    mac_dst=${lacp_mac3}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    tg start all traffic    tg1
    sleep    10
    tg stop all traffic    tg1
    Tg Clear Traffic Stats    tg1

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

    cli     eutA         show interface pon ${service_model.subscriber_point1.attribute.pon_port} counters
    cli     eutA         show interface pon ${service_model.subscriber_point2.attribute.pon_port} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point1.member.interface1} counters
    cli     eutA         show interface ont-ethernet ${service_model.subscriber_point2.member.interface1} counters

    Tg Verify No Traffic Loss For All Streams    tg1
    [Teardown]   case teardown



*** Keywords ***
case setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    mode=ELAN
    log    subscriber_point_l2_basic_svc_provision
    &{res}    subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}    cfg_prefix=mol
    set suite variable    &{res}    &{res}
    subscriber_point_add_svc_user_defined    subscriber_point2    ${service_vlan}    &{res}[policymap]


case teardown
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${service_vlan}    &{res}[policymap]
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}    cfg_prefix=mol
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}