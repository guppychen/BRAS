*** Settings ***
Documentation     Test suite verifies IGMP V2 and video proxy ip
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${start_last_ip}    1

*** Test Cases ***
tc_igmp_v2_proxy_ip
    [Documentation]       Test suite verifies IGMP V2 and video proxy ip
     ...    1. Provision video service with proxy mode on system
     ...    2. system send down query with its proxy IP as src IP
     ...    3. Calix forward join/leave the uplink router with src IP as its proxy IP
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276049    @tcid=AXOS_E72_PARENT-TC-533
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision video service with proxy mode on system (has been provisioned in suite_setup and case_setup)

    log    capture igmp packet
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    log    sleep for prepare capture
    sleep    10s
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp    tg1    igmp_host    join
    
    log    check igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    log    check igmp multicast group
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_network}.${last_ip}
    
    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    
    log    save captured file and analyze
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}
    sleep    10s
    
    log    STEP:2 system send down query with its proxy IP as src IP
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    ...    ((igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]))
    
    log    verify no query packet with origin query ip
    Wsk Load File    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.src == ${p_igmp_querier.ip})) 
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==0

    log    STEP:3 Calix forward join/leave the uplink router with src IP as its proxy IP
    log    verify report packet
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_network}.${last_ip}))
    
    log    verify leave packet
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (igmp.maddr == ${p_mcast_network}.${last_ip}))

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
    