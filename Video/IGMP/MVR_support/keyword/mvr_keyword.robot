*** Settings ***
Documentation    test_suite keyword lib
Resource         ../base.robot

*** Variable ***
${default_gen_query_invl}    1250

*** Keywords ***
create_mvr_prf_with_max_vlan
    [Arguments]    ${device}    ${mvr_prf}    ${vlan_prefix}    ${mc_network_prefix}    ${start_idx}    ${end_idx}
    [Documentation]    create mvr profile with max vlan and ipmc ranges
    [Tags]    @author=CindyGao
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_vlan_prov_limit}+1
    \    ${vlan}    set variable    ${vlan_prefix}${index}
    \    prov_vlan    ${device}    ${vlan}
    \    prov_mvr_profile    ${device}    ${mvr_prf}    ${mc_network_prefix}.${index}.${start_idx}   ${mc_network_prefix}.${index}.${end_idx}    ${vlan}

check_mvr_prf_config_with_max_vlan
    [Arguments]    ${device}    ${mvr_prf}=${EMPTY}    ${vlan_prefix}=${EMPTY}    ${mc_network_prefix}=${EMPTY}    ${start_idx}=${EMPTY}    ${end_idx}=${EMPTY}
    [Documentation]    check mvr profile running config with max vlan and ipmc ranges
    [Tags]    @author=CindyGao
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_vlan_prov_limit}+1
    \    check_running_configure    ${device}    mvr-profile    ${mvr_prf}    address=${mc_network_prefix}.${index}.${start_idx} ${mc_network_prefix}.${index}.${end_idx} ${vlan_prefix}${index}

delete_all_vlan_for_one_mvr_prf
    [Arguments]    ${device}    ${vlan_prefix}
    [Documentation]    delete all max vlan for one mvr profile 
    [Tags]    @author=CindyGao
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_vlan_prov_limit}+1
    \    delete_config_object    ${device}    vlan    ${vlan_prefix}${index}

add_mc_group_and_vlan_to_dict
    [Arguments]    ${dict_group_vlan}    ${mc_network_prefix}    ${grp_session}    ${video_vlan}
    [Documentation]    set mcast_group and video_vlan for "show igmp multicast vlan" check dictionary
    [Tags]    @author=CindyGao
    log    set mcast_group and video_vlan Dictionary
    : FOR    ${index}    IN RANGE    1    ${grp_session}+1
    \    Set To Dictionary    ${dict_group_vlan}    ${mc_network_prefix}.${index}=${video_vlan}

check_subscriber_igmp_multicast_summary_for_mc_session
    [Arguments]    ${subscriber_point}    ${svlan}    ${mc_network_prefix}    ${grp_session}    ${mvr_vlan}=${EMPTY}    ${contain}=yes
    [Documentation]    loop check subscriber_point_check_igmp_multicast_summary for mcast session
    [Tags]    @author=CindyGao
    : FOR    ${last_ip}    IN RANGE    1    ${grp_session}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    ${subscriber_point}    ${svlan}    ${mc_network_prefix}.${last_ip}    ${mvr_vlan}    ${contain}

analyze_igmp_report_packet_for_mc_session
    [Arguments]    ${pkt_file}    ${vlan}    ${src_ip}    ${mc_network_prefix}    ${grp_session}
    [Documentation]    loop check analyze_packet_count_greater_than for igmp_report packet mcast session
    [Tags]    @author=CindyGao
    : FOR    ${last_ip}    IN RANGE    1    ${grp_session}+1
    \    analyze_packet_count_greater_than    ${pkt_file}
    \    ...    (igmp.type == ${igmpv2_type_report}) && (vlan.id == ${vlan}) && (ip.src == ${src_ip}) && (ip.dst == ${mc_network_prefix}.${last_ip})

igmp_simulate_and_capture_packet
    [Arguments]    ${tg}    ${querier_port}    ${host_port}    ${device_cnt}    ${proxy_ip}    ${svlan}
    ...    ${list_video_vlan}    ${list_querier_pbit}    ${list_host_vlan}    ${list_host_pbit}    ${list_host_mc_start}
    [Documentation]    simulate igmp querier and host for input number, capture and save packet
    [Tags]    @author=CindyGao
    log    create IGMP querier
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    create_igmp_querier    ${tg}    igmp_querier${index}    ${querier_port}    ${p_igmp_version}
    \    ...    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{list_video_vlan}[${index}]    ovlan_pbit=@{list_querier_pbit}[${index}]
    
    log    create igmp host
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    ${host_vlan}    Set Variable If    "untagged"=="@{list_host_vlan}[${index}]"    ${EMPTY}    @{list_host_vlan}[${index}]
    \    create_igmp_host    ${tg}    igmp_host${index}    ${host_port}    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    \    ...    ${host_vlan}    ovlan_pbit=@{list_host_pbit}[${index}]    session=1    mc_group_name=mc_group${index}    mc_group_start_ip=@{list_host_mc_start}[${index}]

    log    Perform the following tasks capturing traffic as the receive location for each task: 
    start_capture    ${tg}    ${querier_port}
    start_capture    ${tg}    ${host_port}
    ${gen_query_sec}    evaluate    ${default_gen_query_invl}/10
    sleep    ${gen_query_sec}    sleep ${gen_query_sec} for general-query timer works

    log    igmp querier start and check
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    tg control igmp querier by name    ${tg}    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{list_video_vlan}[${index}]    ${proxy_ip}    ${p_igmp_querier.ip}
    
    log    igmp host join and check
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    tg control igmp    ${tg}    igmp_host${index}    join
    \    ${sub_idx}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point${sub_idx}
    \    ...    ${svlan}    @{list_host_mc_start}[${index}]    @{list_video_vlan}[${index}]
    
    log    create and send downstream mcast traffic
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    create_bound_traffic_udp    ${tg}    ds_mc_traffic_${index}    ${querier_port}    mc_group${index}    igmp_querier${index}    1
    
    Tg Start All Traffic    ${tg}
    sleep    3s    Wait 3s for traffic run
    Tg Stop All Traffic    ${tg}
    
    log    igmp host leave and check
    : FOR    ${index}    IN RANGE    0    ${device_cnt}
    \    tg control igmp    ${tg}    igmp_host${index}    leave
    \    ${sub_idx}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point${sub_idx}
    \    ...    ${svlan}    @{list_host_mc_start}[${index}]    @{list_video_vlan}[${index}]    contain=no
    
    log    stop capture and save packet
    stop_capture    ${tg}    ${querier_port}
    stop_capture    ${tg}    ${host_port}
    ${save_file_querier}    set variable    ${p_tg_store_file_path}/${TEST NAME}_querier.pcap
    ${save_file_host}    set variable    ${p_tg_store_file_path}/${TEST NAME}_host.pcap
    Tg Store Captured Packets   ${tg}    ${querier_port}    ${save_file_querier}
    Tg Store Captured Packets   ${tg}    ${host_port}    ${save_file_host}
    sleep    10s    Wait for save captured packets to ${save_file_querier} and ${save_file_host}
    &{dic_save_file}    create dictionary    querier=${save_file_querier}    host=${save_file_host}
    [Return]    &{dic_save_file}   
    
    