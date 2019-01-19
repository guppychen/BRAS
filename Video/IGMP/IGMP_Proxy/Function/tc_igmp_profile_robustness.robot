*** Settings ***
Documentation     Test suite verifies IGMP V2 igmp-profile robustness
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    robustness
${default_value}    ${p_dflt_igmp_robustness}
${new_value}    8

*** Test Cases ***
tc_igmp_profile_robustness
    [Documentation]    1	send igmp join message from downlink host to join a new group	successful		
    ...    2	capture the igmp packets on uplink	system send two igmp reports out from multicast router interface		
    ...    3	change the robustness to other value	successful		
    ...    4	repeat step 1-2	system send igmp reports number should be the value provision before
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276060    @tcid=AXOS_E72_PARENT-TC-544
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    STEP:1 send igmp join message from downlink host to join a new group successful
    log    start and check igmp router
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

    log    capture igmp packet, start and check igmp multicast group
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s

    log    STEP:2 capture the igmp packets on uplink system send two igmp reports out from multicast router interface
    log    save captured file and analyze
    stop_capture    tg1    service_p1
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    check_igmp_report_count    ${default_value}    ${save_file_service_p1}

    log    STEP:3 change the robustness to other value successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=${new_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute}=${new_value}

    log    STEP:4 repeat step 1-2 system send igmp reports number should be the value provision before
    log    capture igmp packet, start and check igmp multicast group
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    stop_capture    tg1    service_p1
    ${save_file_service_p1_new}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_new.pcap
    check_igmp_report_count    ${new_value}    ${save_file_service_p1_new}

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
    ...    ${p_match_vlan}    mc_group_start_ip=${p_mcast_start_ip}
    
case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile ${attribute}
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    delete tg session
    stop_capture    tg1    service_p1
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host

check_igmp_report_count
    [Arguments]    ${expect_cnt}    ${save_file_name}
    [Documentation]    check capture igmp report packet count equal ${expect_cnt} or ${expect_cnt}+${gen_query_cnt}
    [Tags]    @author=CindyGao
    Tg Store Captured Packets   tg1    service_p1    ${save_file_name}
    log    save captured packets to ${save_file_name}
    sleep    10s
    Wsk Load File    ${save_file_name}
    \    ...    (igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_video_vlan}) && (ip.src == ${p_igmp_querier.ip}) && (ip.dst == ${igmpv2_gen_query_dst_ip})
    ${gen_query_cnt}    wsk_get_total_packet_count
    log    get general query count ${gen_query_cnt}
    log    send igmp report packet count should be ${expect_cnt}+${gen_query_cnt}
    Wsk Load File    ${save_file_name}
    \    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_start_ip})
    ${cnt}    wsk_get_total_packet_count
    Should Be True    (${cnt}==${expect_cnt}) or (${cnt}==${expect_cnt}+${gen_query_cnt})    
    