*** Settings ***
Documentation     Layer3 Applications/Video/Modify Multicast profile name
Resource          ./base.robot


*** Variables ***
${new_mcast_prf}    new_mcast_prf
${mcast_max_stream}    2


*** Test Cases ***
tc_Modify_Multicast_profile_name
    [Documentation]    1	Configure an Multicast profile "X" 	Configuration successful	
    ...    2	Configure Video service using multicast profile "X" with max stream 2	Configuration Successful	
    ...    3	Join and leave channels 	Subsribers are able to Join	
    ...    4	Configure Multicast Profile "Y" with the same mvr profile and use the default max-stream 16	Configuration successful	
    ...    5	Join and leave channels 	Subscribers are able to join
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1468    @globalid=2321537    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure an Multicast profile "X" Configuration successful
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${mcast_max_stream}

    log    STEP:2 Configure Video service using multicast profile "X" with max stream 2 Configuration Successful
    &{dict_prf}    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    Set Test Variable    ${policy_map}    &{dict_prf}[policymap]

    log    STEP:3 Join and leave channels Subsribers are able to Join
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${mcast_max_stream}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    tg control igmp    tg1    igmp_host    join
    : FOR    ${index}    IN RANGE    0    ${mcast_max_stream}
    \    ${last_ip}    evaluate    ${index}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[0]    @{p_mvr_network_list}[0].${last_ip}

    log    more than 2 host can't join channel
    create_igmp_host    tg1    igmp_host2    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${mcast_max_stream}    mc_group_start_ip=@{p_mvr_start_ip_list}[1]
    tg control igmp    tg1    igmp_host2    join
    : FOR    ${index}    IN RANGE    0    ${mcast_max_stream}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[1]    @{p_mvr_start_ip_list}[${index}]    no

    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host2    leave
    log    sleep for igmp leave
    sleep    5s
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

    log    STEP:4 Configure Multicast Profile "Y" with the same mvr profile and use the default max-stream 16 Configuration successful
    prov_multicast_profile    eutA    ${new_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${policy_map}    ${p_mcast_prf}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan}    ${policy_map}    ${new_mcast_prf}
    
    log    STEP:5 Join and leave channels Subscribers are able to join
    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}
    tg control igmp    tg1    igmp_host    join
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: subscriber side provision
    log    create mvr profile 
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]

    log    create IGMP quirier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${new_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${new_mcast_prf}
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}

    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2