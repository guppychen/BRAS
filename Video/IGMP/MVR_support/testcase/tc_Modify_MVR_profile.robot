*** Settings ***
Documentation     Modify MVR profile
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mvr_prf_new}    auto_new_mvr_prf
${mcast_max_stream}    ${p_igmp_group_session_num}

*** Test Cases ***
tc_Layer3_Applications_Video_Modify_MVR_profile
    [Documentation]    1	Configure an MVR profile "X" with a multicast address range and apply it to multicast profile "A"	Configuration successful		
    ...    2	Configure Video service using multicast profile "A"	Configuration Successful		
    ...    3	Join and leave channels within the the MVR range	Subsribers are able to Join		
    ...    4	Join and leave channels outside the the MVR range	Subscribers not able to join		
    ...    5	Configure an MVR profile "Y" with a multicast address range and apply it to multicast profile "A"	Configuration successful		
    ...    6	Join and leave channels within the the MVR range	Subscribers are able to join		
    ...    7	Join and leave channels outside the the MVR range	Subscribers are not able to join		
    ...    8	Modify the max-stream in the multicast profile and verify the maximum allowed channels	
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1467    @globalid=2321536    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure an MVR profile "X" with a multicast address range and apply it to multicast profile "A" Configuration successful
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    log    create multicast profile with ${p_mvr_prf} range1
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    check_running_configure    eutA    multicast-profile    ${p_mcast_prf}    mvr-profile=${p_mvr_prf}

    log    STEP:2 Configure Video service using multicast profile "A" Configuration Successful
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Join and leave channels within the the MVR range Subsribers are able to Join
    log    create igmp_host with range1 mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    cli    eutA    clear igmp statistics vlan vlan-id ${mvr_vlan}
    cli    eutA    clear igmp statistics vlan vlan-id ${p_data_vlan}
    
    tg control igmp    tg1    igmp_host    join
    tg save config into file   tg1     /tmp/mvr.xml
    cli    eutA    show igmp statistics vlan ${mvr_vlan}
    cli    eutA    show igmp statistics vlan ${p_data_vlan}
    
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}

    log    STEP:4 Join and leave channels outside the the MVR range Subscribers not able to join
    log    create igmp_host2 with range2 mc_group_start_ip=@{p_mvr_start_ip_list}[1]
    create_igmp_host    tg1    igmp_host2    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[1]
    tg control igmp    tg1    igmp_host2    join
    log    check igmp multicast group not contain range2
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[1].${last_ip}    no

    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host2    leave

    log    STEP:5 Configure an MVR profile "Y" with a multicast address range and apply it to multicast profile "A" Configuration successful
    log    create mvr profile with range2 mc_group_start_ip=@{p_mvr_start_ip_list}[1]
    prov_mvr_profile    eutA    ${mvr_prf_new}    @{p_mvr_start_ip_list}[1]    @{p_mvr_end_ip_list}[1]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${mvr_prf_new}    ${p_mcast_max_stream}
    check_running_configure    eutA    multicast-profile    ${p_mcast_prf}    mvr-profile=${mvr_prf_new}

    log    STEP:6 Join and leave channels within the the MVR range Subscribers are able to join
    cli    eutA    clear igmp statistics vlan vlan-id ${mvr_vlan}
    cli    eutA    clear igmp statistics vlan vlan-id ${p_data_vlan}
    tg control igmp    tg1    igmp_host2    join
    log    sleep for igmp join
    sleep    5s
    cli    eutA    show igmp statistics vlan ${mvr_vlan}
    cli    eutA    show igmp statistics vlan ${p_data_vlan}
    
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    2min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[1].${last_ip}

    log    STEP:7 Join and leave channels outside the the MVR range Subscribers are not able to join
    tg control igmp    tg1    igmp_host    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}    no

    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host2    leave

    log    STEP:8 Modify the max-stream in the multicast profile and verify the maximum allowed channels
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${mcast_max_stream}
    check_running_configure    eutA    multicast-profile    ${p_mcast_prf}    mvr-profile=${mvr_prf_new}    max-streams=${mcast_max_stream}
    
    cli    eutA    clear igmp statistics vlan vlan-id ${mvr_vlan}
    cli    eutA    clear igmp statistics vlan vlan-id ${p_data_vlan}
    tg control igmp    tg1    igmp_host2    join
    cli    eutA    show igmp statistics vlan ${mvr_vlan}
    cli    eutA    show igmp statistics vlan ${p_data_vlan}
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[1].${last_ip}
    
    log    create igmp host with mc_group_start_ip=@{p_mvr_network_list}[1].(${mcast_max_stream}+1)
    ${new_mc_start_ip}    evaluate    ${mcast_max_stream}+1
    create_igmp_host    tg1    igmp_host3    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_network_list}[1].${new_mc_start_ip}
    tg control igmp    tg1    igmp_host3    join
    log    check igmp multicast group
    : FOR    ${index}    IN RANGE    0    ${p_igmp_group_session_num}
    \    ${last_ip}    evaluate    ${index}+${new_mc_start_ip}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[1].${last_ip}    no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    delete_config_object    eutA    mvr-profile    ${mvr_prf_new}

    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    tg control igmp    tg1    igmp_host3    leave
    tg delete igmp    tg1    igmp_host3