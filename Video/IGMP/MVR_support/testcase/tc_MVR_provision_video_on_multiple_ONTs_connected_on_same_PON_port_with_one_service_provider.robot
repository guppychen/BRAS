*** Settings ***
Documentation     MVR: provision video on multiple ONTs connected on same PON port with one service provider
...    Verify they all can view same channels and different channels at the same time.
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_MVR_provision_video_on_multiple_ONTs_connected_on_same_PON_port_with_one_service_provider
    [Documentation]    MVR: provision video on multiple ONTs connected on same PON port with one service provider
    ...    Verify they all can view same channels and different channels at the same time.
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1457    @globalid=2321525    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 subscriber svc provision
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    
    log    STEP:2 create igmp host
    &{dict_igmp_name1}    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    &{dict_igmp_name2}    create_igmp_host    tg1    igmp_host2    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]    

    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2

    log    STEP:3 Join same channels and check igmp table
    tg control igmp    tg1    igmp_host    join
    tg control igmp    tg1    igmp_host2    join
    log    sleep for igmp join
    sleep    5s
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${index}
    
    &{dict_group_vlan}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Set To Dictionary    ${dict_group_vlan}    @{p_mvr_network_list}[0].${index}=${mvr_vlan}
    
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan}
    
    log    STEP:4 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    &{dict_igmp_name1}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic2    service_p1    &{dict_igmp_name2}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1
    
    log    STEP:5 Join different channels and check igmp table
    tg control igmp    tg1    igmp_host2    leave
    ${new_ip}    evaluate    ${p_igmp_group_session_num}+1
    &{dict_igmp_name3}    create_igmp_host    tg1    igmp_host3    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_network_list}[0].${new_ip}

    tg control igmp    tg1    igmp_host3    join
    log    sleep for igmp join
    sleep    5s
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    1    ${new_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${index}

    &{dict_group_vlan_new}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    ${new_ip}    ${new_ip}+${p_igmp_group_session_num}
    \    Set To Dictionary    ${dict_group_vlan_new}    @{p_mvr_network_list}[0].${index}=${mvr_vlan}
    
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan_new}
    
    log    STEP:6 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic3    service_p1    &{dict_igmp_name3}[mc_grp]    igmp_querier    ${p_mc_traffic_rate_mbps}
    send_traffic_and_check_loss    tg1    subscriber_point1    service_point_list1

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    
    log    mvr provision
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    tg control igmp    tg1    igmp_host3    leave
    tg delete igmp    tg1    igmp_host3
    