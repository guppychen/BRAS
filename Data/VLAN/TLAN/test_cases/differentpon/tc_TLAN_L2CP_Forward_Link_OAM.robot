*** Settings ***
Documentation     802.3 Operations, Administration, and Maintenance
...    (Link-OAM)
Resource          ../base.robot


*** Variables ***
${oam_mac}    01:80:C2:00:00:02


*** Test Cases ***
tc_TLAN_L2CP_Forward_Link_OAM
    [Documentation]    1	Send Link-OAM
    ...    2	Ethertype: 0x8809
    ...    3	Subtype: 0x03
    ...    4	Dest MAC: 01-80-C2-00-00-02
    ...    5	Check STC at egress	L2CP packet is forwarded
    [Tags]       @EUT=NGPON2-4     @TCID=AXOS_E72_PARENT-TC-150    @GlobalID=1584141   @ticket=PREM-23066
    [Setup]      case setup
    TG Create Untagged Stream On Port    tg1    mac1_2    service_p1    subscriber_p1    mac_dst=${oam_mac}    mac_src=${mac1}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
    TG Create Untagged Stream On Port    tg1    mac2_1    subscriber_p1    service_p1    mac_dst=${oam_mac}    mac_src=${mac2}    length_mode=fixed    frame_size=512    rate_pps=${rate_pps50}    ether_type=8809
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

    log    case_teardown
    tg save config into file      tg1       /tmp/TLAN_case_1584141.xml
    log   save done!!!
    sleep      33

    Tg Verify No Traffic Loss For All Streams    tg1
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