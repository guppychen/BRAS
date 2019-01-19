*** Settings ***
Documentation    Max Ranges on VLAN 
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${start_idx}    11
${end_idx}    13
${max_stream}    30

*** Test Cases ***
tc_Max_Ranges_on_VLAN
    [Documentation]
    ...    1	Proxy IGMP mode in use.			
    ...    2	Create mvr profile with max number of ranges on an MVR VLAN	max 8 ranges in an mvr profile		
    ...    3	Add video service to an access interface with max number of ranges on an MVR VLAN.			
    ...    4	Join the following streams for each range: start-1, start, end, end +1.	Only addresses in the range are allowed to join.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1495      @subFeature=MVR support      @globalid=2321564      @priority=P2    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Proxy IGMP mode in use. (Done in init file)
    
    log    STEP:2 Create mvr profile with max number of ranges on an MVR VLAN max 8 ranges in an mvr profile
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_range_per_prf}+1
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    225.${index}.1.${start_idx}    225.${index}.1.${end_idx}    ${mvr_vlan}

    log    STEP:3 Add video service to an access interface with max number of ranges on an MVR VLAN.
    ${start-1}    evaluate    ${start_idx}-1
    ${end+1}    evaluate    ${end_idx}+1
    ${session}    evaluate    ${end+1}-${start-1}+1
    ${max_stream}    evaluate    ${session}*${p_max_mvr_range_per_prf}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:4 Join the following streams for each range: start-1, start, end, end+1. Only addresses in the range are allowed to join.
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_range_per_prf}+1
    \    create_igmp_host    tg1    igmp_host${index}    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    \    ...    ${p_match_vlan}    session=${session}    mc_group_name=mc_group${index}    mc_group_start_ip=225.${index}.1.${start-1}
    \    tg control igmp    tg1    igmp_host${index}    join
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    225.${index}.1.${start_idx}    ${mvr_vlan}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    225.${index}.1.${end_idx}    ${mvr_vlan}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    225.${index}.1.${start-1}    ${mvr_vlan}    contain=no
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    225.${index}.1.${end+1}    ${mvr_vlan}    contain=no

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${p_igmp_version}
    
case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_range_per_prf}+1
    \    tg control igmp    tg1    igmp_host${index}    leave
    \    tg delete igmp    tg1    igmp_host${index}