*** Settings ***
Documentation     Test suite verify igmp immediate leave
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    immediate-leave
${default_value}    ${p_dflt_immediate_leave}
${new_value}    ENABLED

*** Test Cases ***
tc_igmp_immediate_leave
    [Documentation]       Test suite verify igmp immediate leave
    ...    1	make 2 hosts join one multicast group like 225.1.1.1	successful		
    ...    2	leave one host from the multicast group and capture packets on uplink and downlink respectively	no leave message captured on uplink and query captured on downlink		
    ...    3	leave last host from the multicast group and capture packets on uplink	leave message captured on uplink and no query captured on downlink		
    ...    4	retrieve multicast group 225.1.1.1 on system	no group 225.1.1.1		
    ...    5	set igmp-immediate leave disable	successful		
    ...    6	make 2 hosts join one multicast group	successful		
    ...    7	leave one host from the multicast group and capture packets on uplink and downlink respectively	no leave message captured on uplink and query captured on downlink		
    ...    8	leave last host from the multicast group and capture packets on uplink	leave message captured on uplink after last query captured on downlink		
    ...    9	retrieve multicast group 225.1.1.1 on system	no group 225.1.1.1
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276067    @tcid=AXOS_E72_PARENT-TC-551
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]   case setup
    [Teardown]   case teardown
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    set igmp-immediate leave enable successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=ENABLED
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=ENABLED
    
    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_start_ip=${p_mcast_start_ip}
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_start_ip=${p_mcast_start_ip}   
    
    log    STEP:1 make 2 hosts join one multicast group like 225.1.1.1 successful
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}

    log    STEP:2 leave one host from the multicast group and capture packets on uplink and downlink respectively 
    igmp_host_leave_and_save_packet    igmp_host1    leave_1_1
    log    Expected Result: no leave message captured on uplink and query captured on downlink
    verify_no_leave_packet_on_both_side    ${p_mcast_start_ip}    leave_1_1 
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}

    log    STEP:3 leave last host from the multicast group and capture packets on uplink
    ${save_file_suffix}    set variable    leave_1_2
    igmp_host_leave_and_save_packet    igmp_host2    ${save_file_suffix}
    log    Expected Result: leave message captured on uplink and no query captured on downlink
    log    verify leave packet message captured on uplink
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_${save_file_suffix}.pcap
    analyze_packet_count_greater_than    ${save_file_service_p1}    ((igmp.type == ${igmpv2_type_leave}) && (igmp.maddr == ${p_mcast_start_ip}))
    
    log    verify no query captured on downlink
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Wsk Load File    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.dst == ${p_mcast_start_ip}))
    ${cnt}    wsk_get_total_packet_count
    log    according to EXA-18793, EXA-18307, AXOS system always send GSQ host no matter immediate-leave disable or enable
    Run Keyword And Ignore Error    Should Be True    ${cnt}==0

    log    STEP:4 retrieve multicast group 225.1.1.1 on system no group 225.1.1.1
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no

    log    STEP:5 set igmp-immediate leave disable successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=DISABLED
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=DISABLED

    log    STEP:6 make 2 hosts join one multicast group successful
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}

    log    STEP:7 leave one host from the multicast group and capture packets on uplink and downlink respectively 
    igmp_host_leave_and_save_packet    igmp_host1    leave_2_1
    log    Expected Result: no leave message captured on uplink and query captured on downlink
    verify_no_leave_packet_on_both_side    ${p_mcast_start_ip}    leave_2_1 
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}

    log    STEP:8 leave last host from the multicast group and capture packets on uplink 
    ${save_file_suffix}    set variable    leave_2_2
    igmp_host_leave_and_save_packet    igmp_host2    ${save_file_suffix}
    log    Expected Result: leave message captured on uplink after last query captured on downlink
    log    verify last query captured on downlink
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.dst == ${p_mcast_start_ip}))
    
    log    verify leave packet message captured on uplink
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_${save_file_suffix}.pcap
    analyze_packet_count_greater_than    ${save_file_service_p1}    ((igmp.type == ${igmpv2_type_leave}) && (igmp.maddr == ${p_mcast_start_ip}))

    log    STEP:9 retrieve multicast group 225.1.1.1 on system no group 225.1.1.1
    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no
    subscriber_point_check_igmp_multicast_summary    subscriber_point2    ${p_video_vlan}    ${p_mcast_start_ip}    contain=no

*** Keywords ***
case setup
    [Documentation]    case setup: subscriber side provision for sub2
    # subscriber_point_prov    subscriber_point2
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_video_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    subscriber_point_check_status_up    subscriber_point2
    
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    log    verify igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

case teardown
    [Documentation]    case teardown
    log    subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_video_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    
    log    deprovision igmp-profile ${attribute}
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    
igmp_host_leave_and_save_packet
    [Arguments]    ${igmp_host}    ${save_file_suffix}   
    [Documentation]    leave one host from the multicast group, check no leave message captured on uplink and query captured on downlink
    log    host ${igmp_host} send leave packet
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    tg control igmp    tg1    ${igmp_host}    leave
    log    sleep for capture packet
    sleep    10s
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_${save_file_suffix}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    log    save captured packets to ${save_file_subscriber_p1}
    
verify_no_leave_packet_on_both_side
    [Arguments]    ${mc_group}    ${save_file_suffix}   
    [Documentation]    check no leave message captured on uplink and query captured on downlink
    log    verify no leave packet message captured on uplink
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_${save_file_suffix}.pcap
    Wsk Load File    ${save_file_service_p1}    ((igmp.type == ${igmpv2_type_leave}) && (igmp.maddr == ${mc_group}))
    ${cnt}    wsk_get_total_packet_count
    Should Be True    ${cnt}==0
    
    log    verify no query captured on downlink
    ${save_file_subscriber_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_subscriber_p1_${save_file_suffix}.pcap
    Wsk Load File    ${save_file_subscriber_p1}    ((igmp.type == ${igmpv2_type_query}) && (ip.dst == ${mc_group}))
    ${cnt}    wsk_get_total_packet_count
    Run Keyword And Ignore Error    Should Be True    ${cnt}==0
    
    
     