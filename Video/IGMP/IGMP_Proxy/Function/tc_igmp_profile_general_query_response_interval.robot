*** Settings ***
Documentation     Test suite verify igmp-profile general query response interval
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    general-query-response-interval
${default_value}    ${p_dflt_gen_query_response_invl}
${new_value}    200
${query_cnt}    2

*** Test Cases ***
tc_igmp_profile_general_query_response_interval
    [Documentation]       Test suite verify igmp-profile general query response interval
    ...    1	enable igmp proxy on one vlan	successful		
    ...    2	capture the igmp query on host	the max response time in general query is 10s		
    ...    3	change the interval to other value	successful		
    ...    4	capture the igmp query on host	the max response time in general query should be the value provision before
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276059    @tcid=AXOS_E72_PARENT-TC-543
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]   case setup
    [Teardown]   case teardown
    log    modify general-query-interval to short value that reduce case running time
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=${p_gen_query_invl_short}
    ${query_second}    evaluate    (${p_gen_query_invl_short}/10)*${query_cnt}
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}    general-query-interval=${p_gen_query_invl_short}
    
    log    STEP:1 enable igmp proxy on one vlan successful (This step is done with ${p_igmp_prf} in init file)
    ${sub_port_type}    subscriber_point_get_port_type    subscriber_point1
    ${sub_port_name}    set variable    ${service_model.subscriber_point1.name}
    log    deprovision and provision subscriber_point to let new interval query_timer take effect
    dprov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${EMPTY}
    prov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${p_mcast_prf}
    
    log    STEP:2 capture the igmp query on host the max response time in general query is 10s
    start_capture    tg1    subscriber_p1
    log    sleep ${query_second} for general-query timer works
    sleep    ${query_second}
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    log    analyze igmp packet max response time in general query is ${default_value}
    analyze_packet_count_greater_than    ${save_file}
    ...    ((igmp.type == ${igmpv2_type_query}) && (igmp.max_resp == ${default_value}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))

    log    STEP:3 change the interval to other value successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=${new_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${new_value}

    log    STEP:4 capture the igmp query on host the max response time in general query should be the value provision before
    start_capture    tg1    subscriber_p1
    log    sleep ${query_second} for general-query timer works
    sleep    ${query_second}
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}_new.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    log    analyze igmp packet max response time in general query is ${new_value}
    analyze_packet_count_greater_than    ${save_file}
    ...    ((igmp.type == ${igmpv2_type_query}) && (igmp.max_resp == ${new_value}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    # log    create igmp querier
    # create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    # tg control igmp querier by name    tg1    igmp_querier    start
    # log    verify igmp router summary
    # service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    
    # log    create igmp host
    # create_igmp_host    tg1    igmp_host    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    # ...    ${p_match_vlan}    session=1    mc_group_start_ip=${p_mcast_start_ip}
    # log    join and check igmp multicast group
    # tg control igmp    tg1    igmp_host    join
    # Wait Until Keyword Succeeds    1min    2sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}

case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile ${attribute}
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}    general-query-interval
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}    general-query-interval=${p_dflt_gen_query_invl}
    
    # log    delete tg session
    # tg control igmp querier by name    tg1    igmp_querier    stop
    # tg delete igmp querier    tg1    igmp_querier
    # tg control igmp    tg1    igmp_host    leave
    # tg delete igmp    tg1    igmp_host
     