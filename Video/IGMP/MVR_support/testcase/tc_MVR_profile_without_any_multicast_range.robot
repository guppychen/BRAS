*** Settings ***
Documentation     Layer3 Applications/Video/MVR profile without any multicast range
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Layer3_Applications_Video_MVR_profile_without_any_multicast_range
    [Documentation]    1	Configure an MVR profile "X" without any multicast range configured	Configuration successful	
    ...    2	Configure Video service 	Configuration Successful	
    ...    3	Join and leave any channels 	Subsribers will not be able able to Join any multicast group
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1474    @globalid=2321543    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure an MVR profile "X" without any multicast range configured Configuration successful
    prov_mvr_profile    eutA    ${p_mvr_prf}
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:2 Configure Video service Configuration Successful
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    
    log    STEP:3 Join and leave any channels Subsribers will not be able able to Join any multicast group
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    tg control igmp    tg1    igmp_host    join
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    create IGMP quirier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

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
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host