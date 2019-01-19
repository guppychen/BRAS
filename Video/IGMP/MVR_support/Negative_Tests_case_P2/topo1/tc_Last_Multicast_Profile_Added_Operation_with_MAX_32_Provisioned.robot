*** Settings ***
Documentation    Last Multicast Profile Added Operation with MAX(32) Provisioned
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mc_network_prefix}    @{p_mvr_network_list}[0]
${start_idx}    11
${end_idx}    13
${test_mcprf_idx}    ${p_max_mcast_prf_num}


*** Test Cases ***
tc_Last_Multicast_Profile_Added_Operation_with_Max_32_Provisioned
    [Documentation]
    ...    1	Create max number of Multicast Profiles.			
    ...    2	Add video service to an access interface using the last Multicast Profile created on the system.			
    ...    3	Profile created with unique MVR LAN and ranges to any other provisioned. Proxy IGMP mode and MVR in use.			
    ...    4	Create streams for the ranges address: first range -1 address, end-range address, and end-range + 1 address.			
    ...    5	Join all streams.	Only streams inclusive to the multicast profile are forwarded.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1519      @subFeature=MVR support      @globalid=2321588      @priority=P2      @user_interface=CLI      @eut=NGPON2-4 
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Create max number of Multicast Profiles. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mcast_prf_num}+1
    \    prov_multicast_profile    eutA    auto_mcast_prf_${index}

    log    STEP:2 Add video service to an access interface using the first Multicast Profile created on the system. 
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=auto_mcast_prf_${test_mcprf_idx}

    log    STEP:3 Profile created with unique MVR LAN and ranges to any other provisioned. Proxy IGMP mode and MVR in use. 
    ${start-1}    evaluate    ${start_idx}-1
    ${end+1}    evaluate    ${end_idx}+1
    ${session}    evaluate    ${end+1}-${start-1}+1
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${mc_network_prefix}.${start_idx}    ${mc_network_prefix}.${end_idx}    ${mvr_vlan}
    prov_multicast_profile    eutA    auto_mcast_prf_${test_mcprf_idx}    ${p_mvr_prf}

    log    STEP:4 Create streams for the ranges address: first range -1 address, end-range address, and end-range + 1 address. 
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${session}    mc_group_name=mc_group${index}    mc_group_start_ip=${mc_network_prefix}.${start-1}
    
    log    STEP:5 Join all streams. Only streams inclusive to the multicast profile are forwarded. 
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_network_prefix}.${start_idx}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_network_prefix}.${end_idx}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_network_prefix}.${start-1}    ${mvr_vlan}    contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${mc_network_prefix}.${end+1}    ${mvr_vlan}    contain=no

    
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
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=auto_mcast_prf_${test_mcprf_idx}
    log    delete multicast profile
    : FOR    ${index}    IN RANGE    1    ${p_max_mcast_prf_num}+1
    \    delete_config_object    eutA    multicast-profile    auto_mcast_prf_${index}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host