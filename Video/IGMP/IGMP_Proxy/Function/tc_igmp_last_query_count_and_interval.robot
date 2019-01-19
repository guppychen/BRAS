*** Settings ***
Documentation     Test suite verify igmp last query count and interval
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute_cnt}    last-member-query-count
${default_cnt}    ${p_dflt_last_member_query_cnt}
${new_cnt}    3
${attribute_invl}    last-member-query-interval
${default_invl}    ${p_dflt_last_member_query_invl}
${new_invl}    20

*** Test Cases ***
tc_igmp_last_query_count_and_interval
    [Documentation]       Test suite verify igmp last query count and interval
    ...    1	disable igmp immediate leave on system	successful		
    ...    2	make 1 hosts join one multicast group like 225.1.1.1	successful		
    ...    3	leave the host from the multicast group and capture packets on host	the two igmp SQ captured and the max responsed time in packets is 10s		
    ...    4	change rhe count and interval to other values	successful		
    ...    5	repeat step 2-4	the number of igmp SQ send to host and the interval should be consist with the provision
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276068    @tcid=AXOS_E72_PARENT-TC-552
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]   case setup
    [Teardown]   case teardown
    log    STEP:1 disable igmp immediate leave on system successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    immediate-leave=DISABLED
    log    check ${attribute_cnt} and ${attribute_invl} is default value
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    immediate-leave=DISABLED
    ...    ${attribute_cnt}=${default_cnt}    ${attribute_invl}=${default_invl}

    log    STEP:2 make 1 hosts join one multicast group like 225.1.1.1 successful
    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_start_ip=${p_mcast_start_ip}
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}

    log    STEP:3 leave the host from the multicast group and capture packets on host the two igmp SQ captured and the max responsed time in packets is 10s
    ${query_sec}    evaluate    (${p_dflt_last_member_query_invl}/10)*${p_dflt_last_member_query_cnt}
    ${save_file_suffix}    set variable    last_sq_1
    igmp_host_leave_and_save_packet    igmp_host1    ${save_file_suffix}    ${query_sec}
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Wsk Load File    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.dst == ${p_mcast_start_ip}))
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==${p_dflt_last_member_query_cnt}

    log    STEP:4 change rhe count and interval to other values successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute_cnt}=${new_cnt}    ${attribute_invl}=${new_invl}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute_cnt}=${new_cnt}    ${attribute_invl}=${new_invl}

    log    STEP:5 repeat step 2-4 the number of igmp SQ send to host and the interval should be consist with the provision
    log    igmp host join and check
    tg control igmp    tg1    igmp_host1    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    
    log    leave the host from the multicast group and capture packets on host the igmp SQ send to host and the interval should be consist with the provision
    ${query_sec}    evaluate    (${new_invl}/10)*${new_cnt}
    ${save_file_suffix}    set variable    last_sq_2
    igmp_host_leave_and_save_packet    igmp_host1    ${save_file_suffix}    ${query_sec}
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Wsk Load File    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.dst == ${p_mcast_start_ip}))
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==${new_cnt}

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    log    verify igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile config
    dprov_igmp_profile    eutA    ${p_igmp_prf}    immediate-leave    ${attribute_cnt}    ${attribute_invl}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    immediate-leave=${p_dflt_immediate_leave}
    ...    ${attribute_cnt}=${default_cnt}    ${attribute_invl}=${default_invl}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    
igmp_host_leave_and_save_packet
    [Arguments]    ${igmp_host}    ${save_file_suffix}   ${sleep_sec}=10s
    [Documentation]    leave one host from the multicast group, check no leave message captured on uplink and query captured on downlink
    log    host ${igmp_host} send leave packet
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    ${igmp_host}    leave
    log    sleep for capture packet
    sleep    ${sleep_sec}
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_${save_file_suffix}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_subscriber_p1}
     