*** Settings ***
Documentation     Modify Stream Limit Increase with MVR
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mcast_max_stream}    ${p_igmp_group_session_num}

*** Test Cases ***
tc_Modify_Stream_Limit_Increase_with_MVR
    [Documentation]    1	Add basic video service to the access interface using any stream limit value and very low query interval. Proxy IGMP mode in use. 			
    ...    2	Actively join the limit +1 streams. 	The streams forwarded are limited to the provisioned limit decreasing as the limit decreases.		
    ...    3	Increase the limit by one. 			
    ...    4	Stop all active joins and wait for query interval. Restart active joins.	The streams forwarded are limited to the provisioned limit increasing as the limit increases.		
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1522    @globalid=2321591    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Add basic video service to the access interface using any stream limit value and very low query interval. Proxy IGMP mode in use.
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=${p_gen_query_invl1}
    ${query_second}    evaluate    ${p_gen_query_invl1}/10
    
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Actively join the limit +1 streams. The streams forwarded are limited to the provisioned limit decreasing as the limit decreases.
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host    join
    : FOR    ${last_ip}    IN RANGE    1    ${mcast_max_stream}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}

    log    more host can't join channel
    ${more_ip_index}    evaluate    ${mcast_max_stream}+1
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    mc_group_start_ip=@{p_mvr_network_list}[0].${more_ip_index}
    tg control igmp    tg1    igmp_host2    join
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${mvr_vlan}    @{p_mvr_network_list}[0].${more_ip_index}    no

    log    STEP:3 Increase the limit by one.
    ${new_max_stream}    evaluate    ${mcast_max_stream}+1
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${new_max_stream}
    check_running_configure    eutA    multicast-profile    ${p_mcast_prf}    max-streams=${new_max_stream}

    log    STEP:4 Stop all active joins and wait for query interval. Restart active joins. The streams forwarded are limited to the provisioned limit increasing as the limit increases.
    tg control igmp    tg1    igmp_host    leave
    tg control igmp    tg1    igmp_host2    leave
    sleep    ${query_second}    Wait for igmp query interval
    tg control igmp    tg1    igmp_host    join
    tg control igmp    tg1    igmp_host2    join
    : FOR    ${last_ip}    IN RANGE    1    ${new_max_stream}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}


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
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_igmp_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    rollback igmp profile provision the same as init file mvr_suite_provision
    dprov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval

    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2