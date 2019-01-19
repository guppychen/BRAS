*** Settings ***
Documentation     MVR: provision video on multiple ONTs connected on different PON port with one service provider
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${org_grp}    @{p_mvr_start_ip_list}[0]
${new_grp}    @{p_mvr_end_ip_list}[0]

*** Test Cases ***
tc_MVR_provision_video_on_multiple_ONTs_connected_on_different_PON_port_with_one_service_provider
    [Documentation]    provision video on multiple ONTs connected on different PON port with one service provider
    ...    Verify they all can view same channels and different channels at the same time.
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1458    @globalid=2321526    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 subscriber svc provision with mvr
    log    mvr provision
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${org_grp}    ${new_grp}    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point3    ${p_match_vlan_sub3}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub3
    
    log    STEP:2 create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_grp1    mc_group_start_ip=${org_grp}  
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub3}    session=1    mc_group_name=mc_grp2    mc_group_start_ip=${org_grp}    
    
    log    STEP:3 Join same channels and check igmp table
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${org_grp}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point3    ${p_data_vlan}    ${org_grp}    ${mvr_vlan}
    
    log    STEP:4 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic1    service_p1    mc_grp1    igmp_querier    ${p_mc_traffic_rate_mbps}
    create_bound_traffic_udp    tg1    ds_mc_traffic2    service_p1    mc_grp2    igmp_querier    ${p_mc_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep ${p_traffic_run_time} for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep ${p_traffic_stop_time} for traffic stop
    sleep    ${p_traffic_stop_time}
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic1    ${p_traffic_loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic2    ${p_traffic_loss_rate}
    
    log    STEP:5 Join different channels and check igmp table
    tg control igmp    tg1    igmp_host1    leave
    create_igmp_host    tg1    igmp_host3    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=1    mc_group_name=mc_grp3    mc_group_start_ip=${new_grp}

    tg control igmp    tg1    igmp_host3    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${new_grp}    ${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    ${org_grp}    ${mvr_vlan}    contain=no
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point3    ${p_data_vlan}    ${org_grp}    ${mvr_vlan}
    
    log    STEP:6 send multicast downstream traffic and verify no drop packet
    create_bound_traffic_udp    tg1    ds_mc_traffic3    service_p1    mc_grp3    igmp_querier    ${p_mc_traffic_rate_mbps}
    TG Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log    sleep ${p_traffic_run_time} for traffic run
    sleep    ${p_traffic_run_time}
    Tg Stop All Traffic    tg1
    log    sleep ${p_traffic_stop_time} for traffic stop
    sleep    ${p_traffic_stop_time}
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic2    ${p_traffic_loss_rate}
    Tg Verify Traffic Loss For Stream Is Within    tg1    ds_mc_traffic3    ${p_traffic_loss_rate}

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point3
    
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc    subscriber_point3    ${p_match_vlan_sub3}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub3

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    tg control igmp    tg1    igmp_host3    leave
    tg delete igmp    tg1    igmp_host3
    