*** Settings ***
Documentation     Test suite verify igmp start up query count and interval
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute_cnt}    startup-query-count
${default_cnt}    ${p_dflt_startup_query_cnt}
${new_cnt}    3
${attribute_invl}    startup-query-interval
${default_invl}    ${p_dflt_startup_query_invl}
${new_invl}    200

*** Test Cases ***
tc_igmp_profile_start_up_count_and_interval
    [Documentation]       Test suite verify igmp start up query count and interval
    ...    1	connect STB to ONT port and capture the igmp packets 	the start up igmp query should be 2 and interval is 15		
    ...    2	change the count and interval to other value	successful		
    ...    3	disconnect the STB and ONT port and re-connect	the start up igmp query number and interval should be the value provision before
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276062    @tcid=AXOS_E72_PARENT-TC-546
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]   case setup
    [Teardown]   case teardown
    ${sub_port_type}    subscriber_point_get_port_type    subscriber_point1
    ${sub_port_name}    set variable    ${service_model.subscriber_point1.name}
    
    log    check ${attribute_cnt} and ${attribute_invl} is default value
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute_cnt}=${default_cnt}    ${attribute_invl}=${default_invl}
    ${startup_query_second}    evaluate    (${default_invl}/10)*${default_cnt}
    
    log    STEP:1 connect STB to ONT port and capture the igmp packets 
    start_capture    tg1    subscriber_p1
    log    deprovision and provision static host subscriber_point trigger startup_query
    dprov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${EMPTY}
    prov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${p_mcast_prf}
    
    log    sleep ${startup_query_second} for startup-query timer works
    sleep    ${startup_query_second}
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    
    log    Verify: the start up igmp query should be ${default_cnt} and interval is ${default_invl}/10
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file}
    ...    ((igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))
    log    system will create startup query timer to pon port and ont port, so if sub_port_type is ont, receive pkt_cnt should be twice
    ${weight}    set variable if    'ont_port'=='${service_model.subscriber_point1.type}'    2    1
    should be true    abs(${pkt_cnt}-(${default_cnt}*${weight}))<(${pkt_cnt}+1)
    
    log    STEP:2 change the count and interval to other value successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute_cnt}=${new_cnt}    ${attribute_invl}=${new_invl}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute_cnt}=${new_cnt}    ${attribute_invl}=${new_invl}
    ${startup_query_second}    evaluate    (${new_invl}/10)*${new_cnt}

    log    STEP:3 disconnect the STB and ONT port and re-connect
    start_capture    tg1    subscriber_p1
    log    deprovision and provision static host subscriber_point trigger startup_query
    dprov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${EMPTY}
    prov_interface    eutA    ${sub_port_type}    ${sub_port_name}    ${p_video_vlan}    igmp multicast-profile=${p_mcast_prf}
    
    log    sleep ${startup_query_second} for startup-query timer works
    sleep    ${startup_query_second}
    stop_capture    tg1    subscriber_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}_new.pcap
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file}
    log    save captured packets to ${save_file}
    
    log    Verify: the start up igmp query number and interval should be the value provision before
    ${pkt_cnt}    analyze_packet_count_greater_than    ${save_file}
    ...    ((igmp.type == ${igmpv2_type_query}) && (vlan.id == ${p_match_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${igmpv2_gen_query_dst_ip}))

    should be true    abs(${pkt_cnt}-(${new_cnt}*${weight}))<(${pkt_cnt}+1)

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1

case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile config
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute_cnt}    ${attribute_invl}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute_cnt}=${default_cnt}    ${attribute_invl}=${default_invl}
