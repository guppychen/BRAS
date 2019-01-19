*** Settings ***
Documentation     Calix Video Services shall support retrieval of MVR membership on a per Multicast address basis
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Layer3_Applications_Video_MVR_membership_per_address
    [Documentation]    1	Configure an MVR profile	MVR profile is created		
    ...    2	Apply the MVR profile to a subscriber port	Configuration is sucessful		
    ...    3	Create IGMP client on STC and join the channel within the range specified in MVR	IGMP clients should be able to join the channels		
    ...    4	Run the show command that displays the subscribe (uni port) joined the specified channel	Show command output displays the appropriate result
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1447    @globalid=2321515    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure an MVR profile MVR profile is created
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan}

    log    STEP:2 Apply the MVR profile to a subscriber port Configuration is sucessful
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Create IGMP client on STC and join the channel within the range specified in MVR IGMP clients should be able to join the channels
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    tg control igmp    tg1    igmp_host1    join
    
    log    STEP:4 Run the show command that displays the subscribe (uni port) joined the specified channel Show command output displays the appropriate result
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1
    \    ...    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}    summary=no


*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
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
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1