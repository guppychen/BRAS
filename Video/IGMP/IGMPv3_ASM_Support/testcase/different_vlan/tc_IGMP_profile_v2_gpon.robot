*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_IGMP_profile_v2_gpon
    [Documentation]    1	Provision IGMP version as v2 and connect V2 router and STB on gpon subscriber port. The IGMP profile is proxy and using default value on other attribute	Video traffic flowing fine. Capture traffic and it follow the IGMP profile attribute setting like query interval etc.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2253    @GlobalID=2346520
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision IGMP version as v2 and connect V2 router and STB on gpon subscriber port. The IGMP profile is proxy and using default value on other attribute Video traffic flowing fine. Capture traffic and it follow the IGMP profile attribute setting like query interval etc.

    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v2    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start
    start_capture    tg1    subscriber_p1

    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V2
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]

    log    wait for general query timeout
    sleep    ${general_query_timeout}
    log    save captured file and analyze
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2253.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    (igmp.type==0x11) && (ip.addr == @{p_proxy_1.ip}[0]) && (ip.dst==224.0.0.1) && (igmp.max_resp == 100) && (igmp.maddr == 0.0.0.0)


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2253 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2253 teardown
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}