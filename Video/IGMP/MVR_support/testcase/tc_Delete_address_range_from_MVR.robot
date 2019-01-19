*** Settings ***
Documentation     Layer3 Applications/Video/Delete address range from MVR 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Layer3_Applications_Video_Delete_address_range_from_MVR
    [Documentation]    1	Configure an MVR profile "X" with multiple multicast address range and apply it to multicast profile "A"	Configuration successful	
    ...    2	Configure Video service using multicast profile "A"	Configuration Successful	
    ...    3	Join and leave channels within the the MVR range	Subsribers are able to Join	
    ...    4	Delete one of the range from the MVR profile X	Subscribers not able to join	
    ...    5	Join and leave channels within the the the deleted range	Subscribers are not able to join	
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1475    @globalid=2321544    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure an MVR profile "X" with multiple multicast address range and apply it to multicast profile "A" Configuration successful
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:2 Configure Video service using multicast profile "A" Configuration Successful
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Join and leave channels within the the MVR range Subsribers are able to Join
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    tg control igmp    tg1    igmp_host    join
    log    check igmp table
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

    log    STEP:4 Delete one of the range from the MVR profile X Subscribers not able to join
    dprov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[0]

    log    STEP:5 Join and leave channels within the the the deleted range Subscribers are not able to join
    tg control igmp    tg1    igmp_host    join
    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_start_ip_list}[0]    no


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
