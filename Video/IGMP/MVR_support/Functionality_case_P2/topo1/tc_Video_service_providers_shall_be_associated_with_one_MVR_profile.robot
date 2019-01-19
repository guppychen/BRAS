*** Settings ***
Documentation     Video service providers shall be associated with one MVR profile. 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Video_service_providers_shall_be_associated_with_one_MVR_profile
    [Documentation]    Each video provider is represented by a unique MVR profile 
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1450    @globalid=2321518    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    create 4 IGMP quirier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    Configure an MVR profile that uses 4 vlans with different multicast address range for 4 IGMP quirier
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    log    Configure subscriber point
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    
    tg control igmp    tg1    igmp_host1    join
    log    get mcast_group and video_vlan Dictionary
    ${dict_group_vlan}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    add_mc_group_and_vlan_to_dict    ${dict_group_vlan}    @{p_mvr_network_list}[${index}]    ${p_igmp_group_session_num}    @{p_video_vlan_list}[${index}]
    
    log    check igmp multicast vlan for subscriber_point1
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}
    
    tg control igmp    tg1    igmp_host1    leave
    log    check igmp multicast summary not contain for subscriber_point1
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    check_subscriber_igmp_multicast_summary_for_mc_session    subscriber_point1    ${p_data_vlan}    @{p_mvr_network_list}[${index}]    ${p_igmp_group_session_num}    @{p_video_vlan_list}[${index}]    contain=no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1
    
    log    create igmp host for subscriber_point1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_multicast_group_to_igmp_host    tg1    igmp_host1    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}    mc_grp_prefix=mc_grp_sub1

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
