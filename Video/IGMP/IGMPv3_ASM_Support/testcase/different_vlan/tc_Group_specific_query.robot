*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Group_specific_query
    [Documentation]    1	capture traffic on subscriber side.	Group specific query for the channel just left has: type = 0x11. Source IP = system proxy IP. Dest IP = leaved multicast address.Max responding time = 1 sec (default). Group address = IP address for the channel just left. Number of source = 1. Robustness = 2 (last member query count). Query interval = 1 second. The sub that still viewing the first channel responding with report (Is-include record).
    ...    2	Edit the IGMP profile has last member query count = 8; last member query interval = 5 sec; then capture traffic on subscriber side	Group specific query pkt has: query count = 8; query interval = 5 sec.
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2270    @GlobalID=2346537
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 capture traffic on subscriber side. Group specific query for the channel just left has: type = 0x11. Source IP = system proxy IP. Dest IP = leaved multicast address.Max responding time = 1 sec (default). Group address = IP address for the channel just left. Number of source = 1. Robustness = 2 (last member query count). Query interval = 1 second. The sub that still viewing the first channel responding with report (Is-include record).

    log    STEP:2 Edit the IGMP profile has last member query count = 8; last member query interval = 5 sec; then capture traffic on subscriber side Group specific query pkt has: query count = 8; query interval = 5 sec.

    log    case setup: subscriber side provision
    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start

    tg save config into file    tg1   /tmp/igmpv3_two_reset.xml
    
    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    log    Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host1    subscriber_p1    v3    ${p_igmp_host1.mac}    ${p_igmp_host1.ip}    ${p_igmp_host1.gateway}    ${p_match_vlan_switch1}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}
    
    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    ont leave the group
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    igmp_host1    leave
    sleep    ${wait_igmp_client_join_leave}
    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    @{service_model.subscriber_point1.attribute.pon_port}[0]
    check_igmp_multicast_summary_not_contain    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    save captured file and analyze
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2270.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    # AT-3973
    IGMPV3_ASM_keyword.analyze_packet_count_equal    ${save_file}    (igmp.type==0x11) && (ip.addr == @{p_proxy_1.ip}[0]) && (ip.dst==@{p_mvr_start_ip_list}[0]) && (eth.src contains ${src_mac_prefix})   2
    # AT-3973

    log    change the igmp profile last member query count to 8
    prov_igmp_profile    eutA    ${p_igmp_profile1}    last-member-query-count=8

    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}
    log    check igmp multicast group on subscriber connected device
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]
    check_igmp_multicast_summary    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    ont leave the group
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    igmp_host1    leave
    sleep    10
    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    @{service_model.subscriber_point1.attribute.pon_port}[0]
    check_igmp_multicast_summary_not_contain    eutA    ${p_data_vlan}    ${service_model.subscriber_point1.member.interface1}    @{p_mvr_start_ip_list}[0]    @{p_video_vlan_list}[0]

    log    save captured file and analyze
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/TC-2270-1.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    ${wait_to_save_file}
    log    analyze imgp packet
    log    this step can be pass because of EXA-18850 won't fix
    IGMPV3_ASM_keyword.analyze_packet_count_equal    ${save_file}    (igmp.type==0x11) && (ip.addr == @{p_proxy_1.ip}[0]) && (ip.dst==@{p_mvr_start_ip_list}[0]) && (eth.src contains ${src_mac_prefix})    2


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2270 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2270 teardown
    log    change the igmp profile last member query count to 8
    prov_igmp_profile    eutA    ${p_igmp_profile1}    last-member-query-count=2
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    tg delete igmp    tg1    igmp_host1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}
