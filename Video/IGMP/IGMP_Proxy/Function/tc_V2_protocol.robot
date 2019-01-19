*** Settings ***
Documentation     Test suite verifies IGMP V2 protocol
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${start_last_ip}    1

*** Test Cases ***
tc_V2_protocol
    [Documentation]       Test suite verifies IGMP V2 protocol
    ...    1	Provision video service with proxy mode on system	successful		
    ...    2	send igmp query to the uplink port	System send general query periodically.		
    ...    3	host send igmp report packet	
    ...         System forward the new join message to uplink router and add the channel from snooping table accordingly, 
    ...         and response the router query with all the joined channels.		
    ...    4	host send leave packet	
    ...         System send out group query response to the channel leave received on the access interface. 
    ...         System forward the new leave message to uplink router and remove the channel from snooping table accordingly.
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276048    @tcid=AXOS_E72_PARENT-TC-532
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision video service with proxy mode on system successful (has been provisioned in suite_setup and case_setup)

    log    STEP:2 send igmp query to the uplink port 
    start_capture    tg1    subscriber_p1
    tg control igmp querier by name    tg1    igmp_querier    start
    ${query_second}    evaluate    ${p_dflt_gen_query_invl}/10
    log    sleep for capture packet
    sleep    ${query_second}   
    
    log    check igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    log    Verify system send general query periodically
    stop_capture    tg1    subscriber_p1
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_subscriber_p1}
    log    verify general query packet
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    ((igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))

    log    STEP:3 host send igmp report packet
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    
    log    Verify system forward the new join message to uplink router and add the channel from snooping table accordingly, 
    log    check igmp multicast summary
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_network}.${last_ip}
    
    log    Verify system response the router query with all the joined channels.
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    log    verify report packet
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_network}.${last_ip}))

    log    STEP:4 host send leave packet 
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    igmp_host    leave
    log    sleep for capture packet
    sleep    10s
    
    log    Verify system send out group query response to the channel leave received on the access interface. 
    stop_capture    tg1    subscriber_p1
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_leave.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_subscriber_p1}
    log    verify group query packet
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    \    ...    ((igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_network}.${last_ip}))
    
    log    Verify system forward the new leave message to uplink router and remove the channel from snooping table accordingly.
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_leave.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    log    verify leave packet
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (igmp.maddr == ${p_mcast_network}.${last_ip}))
    
    log    check igmp multicast summary not contain
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1
    \    ...    ${p_video_vlan}    ${p_mcast_network}.${last_ip}    contain=no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1 
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=${p_mcast_network}.${start_last_ip}
    
case teardown
    [Documentation]    case teardown
    log    delete tg session
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    