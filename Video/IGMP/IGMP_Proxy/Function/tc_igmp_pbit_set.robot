*** Settings ***
Documentation     Test suite verifies IGMP pbit set
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${attribute}    pbit-priority
${default_value}    ${p_dflt_igmp_pbit}
${new_value}    7

*** Test Cases ***
tc_igmp_pbit_set
    [Documentation]    1	send the igmp join message from host to system	successful		
    ...    2	capture the igmp packets on uplink	default pbit of igmp packet is set to 5		
    ...    3	change the pbit to other value 7 or 0	successful		
    ...    4	capture the igmp packets on uplink	the pbit in packets should be 7 or 0
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276057    @tcid=AXOS_E72_PARENT-TC-541
    ...    @user_interface=CLI    @priority=P2    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    check ${attribute} is default value ${default_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    STEP:1 send the igmp join message from host to system successful
    start_capture    tg1    service_p1
    tg control igmp querier by name    tg1    igmp_querier    start
    tg control igmp    tg1    igmp_host    join
    
    log    check igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}
    log    check igmp multicast summary
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s

    log    STEP:2 capture the igmp packets on uplink default pbit of igmp packet is set to ${default_value}
    stop_capture    tg1    service_p1
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    sleep    10s
    log    verify report packet pbit is set to ${default_value}
    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (vlan.priority == ${default_value}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_start_ip}))
    log    verify leave packet pbit is set to ${default_value}
    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_video_vlan}) && (vlan.priority == ${default_value}) && (ip.src == @{p_proxy.ip}[0]) && (igmp.maddr == ${p_mcast_start_ip}))

    log    STEP:3 change the pbit to other value 7 or 0 successful
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}=${new_value}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    ${attribute}=${new_value}

    log    STEP:4 capture the igmp packets on uplink the pbit in packets should be 7 or 0
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    log    check igmp multicast summary
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_start_ip}

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    stop_capture    tg1    service_p1
    ${save_file_service_p1}    set variable    ${p_tg_store_file_path}/${TEST NAME}_service_p1_new.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    log    save captured packets to ${save_file_service_p1}
    sleep    10s
    log    verify report packet pbit is set to ${default_value}
    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_report}) && (vlan.id == ${p_video_vlan}) && (vlan.priority == ${new_value}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == ${p_mcast_start_ip}))
    log    verify leave packet pbit is set to ${default_value}
    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    ((igmp.type == ${igmpv2_type_leave}) && (vlan.id == ${p_video_vlan}) && (vlan.priority == ${new_value}) && (ip.src == @{p_proxy.ip}[0]) && (igmp.maddr == ${p_mcast_start_ip}))
    
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
    ...    ${p_match_vlan}    session=1    mc_group_start_ip=${p_mcast_start_ip}
    
case teardown
    [Documentation]    case teardown
    log    deprovision igmp-profile ${attribute}
    dprov_igmp_profile    eutA    ${p_igmp_prf}    ${attribute}
    check_running_configure    eutA    igmp-profile    ${p_igmp_prf}    | detail    ${attribute}=${default_value}
    
    log    delete tg session
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    