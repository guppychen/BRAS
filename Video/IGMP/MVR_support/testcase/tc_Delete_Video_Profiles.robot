*** Settings ***
Documentation     Layer3 Applications/Video/Delete Video Profiles
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Layer3_Applications_Video_Delete_Video_Profiles
    [Documentation]    1	Configure IGMP profile "X"	Configuration successful	
    ...    2	Delete IGMP profile "X"	Deletion successful	
    ...    3	Configure Multicast profile "X"	Configuration Successful	
    ...    4	Delete Multicast profile "X"	Deletion successful	
    ...    5	Configure MVR profile "X"	Configuration successful	
    ...    6	Delete MVR profile "X"	Deletion successful	
    ...    7	Configure IGMP, Multicast and MVR profile and apply them appropriately to the the video service	Video service configured with all the video profiles	
    ...    8	Join and leave channels	Subscribers are not able to join	
    ...    9	Delete MVR profile which is in use by a video subscriber	Deletion unsuccessful, error returned	
    ...    10	Delete Multicast profile which is in use by a video subscriber	Deletion unsuccessful, error returned	
    ...    11	Delete IGMP profile which is in use by a video subscriber	Deletion unsuccessful, error returned
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1472    @globalid=2321541    @priority=P1    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure IGMP profile "X" Configuration successful
    prov_igmp_profile    eutA    igmp_prf_test    auto

    log    STEP:2 Delete IGMP profile "X" Deletion successful
    delete_config_object    eutA    igmp-profile    igmp_prf_test

    log    STEP:3 Configure Multicast profile "X" Configuration Successful
    prov_multicast_profile    eutA    ${p_mcast_prf} 

    log    STEP:4 Delete Multicast profile "X" Deletion successful
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}

    log    STEP:5 Configure MVR profile "X" Configuration successful
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]

    log    STEP:6 Delete MVR profile "X" Deletion successful
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}

    log    STEP:7 Configure IGMP, Multicast and MVR profile and apply them appropriately to the the video service Video service configured with all the video profiles
    log    create mvr profile 
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}   
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   

    log    STEP:8 Join and leave channels Subscribers are not able to join
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}
    
    tg control igmp    tg1    igmp_host    join
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]

    tg control igmp    tg1    igmp_host    leave
    log    sleep for igmp leave
    sleep    5s
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_multicast_group    subscriber_point1    @{p_video_vlan_list}[${index}]    @{p_mvr_start_ip_list}[${index}]    no

    log    STEP:9 Delete MVR profile which is in use by a video subscriber Deletion unsuccessful, error returned
    ${status}    ${info}    Run Keyword And Ignore Error    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    should contain    ${info}    Aborted: illegal reference

    log    STEP:10 Delete Multicast profile which is in use by a video subscriber Deletion unsuccessful, error returned
    ${status}    ${info}    Run Keyword And Ignore Error    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    should contain    ${info}    Aborted: illegal reference

    log    STEP:11 Delete IGMP profile which is in use by a video subscriber Deletion unsuccessful, error returned
    ${status}    ${info}    Run Keyword And Ignore Error    delete_config_object    eutA    igmp-profile    ${p_igmp_prf}
    should contain    ${info}    Aborted: illegal reference

*** Keywords ***
case setup
    [Documentation]    case setup
    log    case setup: subscriber side provision
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