*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***
${general_query_timeout}    125s

*** Test Cases ***
tc_General_query
    [Documentation]    1	capture traffic subscriber side.	General query pkt system proxy send down has Typle = 0x11. IP source = system proxy address. IP dest= 224.0.0.1.Max responding time = 10 sec. Group IP address = 0.0.0.0.robustness = 1; Query interval = 60.
    ...    2	Edit the IGMP profile has robustness = 10; query responding time = 20; query interval = 250; then capture traffic on subscriber side	General query pkt RX on the subscriber side has: robustness = 10; max query resonding = 20; query interval = 250
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2269    @GlobalID=2346536
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 capture traffic subscriber side. General query pkt system proxy send down has Typle = 0x11. IP source = system proxy address. IP dest= 224.0.0.1.Max responding time = 10 sec. Group IP address = 0.0.0.0.robustness = 1; Query interval = 60.

    log    STEP:2 Edit the IGMP profile has robustness = 10; query responding time = 20; query interval = 250; then capture traffic on subscriber side General query pkt RX on the subscriber side has: robustness = 10; max query resonding = 20; query interval = 250

    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start
    start_capture    tg1    subscriber_p1

    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    log    wait for general query timeout
    sleep    ${general_query_timeout}
    log    save captured file and analyze
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2269.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    (igmp.type==0x11) && (ip.addr == @{p_proxy_1.ip}[0]) && (ip.dst==224.0.0.1) && (igmp.max_resp == 100) && (igmp.maddr == 0.0.0.0)

    log    change the igmp profile general-query-response-interval to 200
    prov_igmp_profile    eutA    ${p_igmp_profile1}    general-query-response-interval=200

    start_capture    tg1    subscriber_p1
    log    wait for general query timeout
    sleep    ${general_query_timeout}
    log    save captured file and analyze
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2269-1.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    analyze_packet_count_greater_than    ${save_file}    (igmp.type==0x11) && (ip.addr == @{p_proxy_1.ip}[0]) && (ip.dst==224.0.0.1) && (igmp.max_resp == 200) && (igmp.maddr == 0.0.0.0)

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2269 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2269 teardown
    log    change the igmp profile general-query-response-interval to 100
    prov_igmp_profile    eutA    ${p_igmp_profile1}    general-query-response-interval=100
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}