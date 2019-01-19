*** Settings ***
Documentation    Last MVR Profile Added Operation with Max(8) Provisioned 
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${start_idx}    11
${end_idx}    13

*** Test Cases ***
tc_Last_MVR_Profile_Added_Operation_with_Max_8_Provisioned
    [Documentation]
    ...    1	Create max number of MVR Profiles with max VLANs and max ranges.			
    ...    2	Add video service to an access interface using the last MVR Profile created on the system.  Profile created with unique MVR LAN and ranges to any other provisioned. 			
    ...    3	Proxy IGMP mode and MVR in use.			
    ...    4	Create streams for the ranges address: first range -1 address, end-range address, and end-range + 1 address. Join all streams.	Only streams inclusive to the MVR Profile range are forwarded.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1500      @subFeature=MVR support      @globalid=2321569      @priority=P2    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Create max number of MVR Profiles with max VLANs and max ranges. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}
    \    create_mvr_prf_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    226.${index}    ${start_idx}    ${end_idx}

    log    provision last mvr profile
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_range_per_prf}+1
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    225.${index}.1.${start_idx}    225.${index}.1.${end_idx}    ${mvr_vlan}

    log    STEP:2 Add video service to an access interface using the last MVR Profile created on the system. Profile created with unique MVR LAN and ranges to any other provisioned. 
    ${start-1}    evaluate    ${start_idx}-1
    ${end+1}    evaluate    ${end_idx}+1
    ${session}    evaluate    ${end+1}-${start-1}+1
    ${max_stream}    evaluate    ${session}*${p_max_mvr_range_per_prf}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Proxy IGMP mode and MVR in use (Done in init file)     

    log    STEP:4 Create streams for the ranges address: first range -1 address, end-range address, and end-range + 1 address. Join all streams. Only streams inclusive to the MVR Profile range are forwarded. 
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
    log    delete mvr config
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    \    delete_all_vlan_for_one_mvr_prf    eutA    ${p_prov_vlan_prefix}${index}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_range_per_prf}+1
    \    tg control igmp    tg1    igmp_host${index}    leave
    \    tg delete igmp    tg1    igmp_host${index}