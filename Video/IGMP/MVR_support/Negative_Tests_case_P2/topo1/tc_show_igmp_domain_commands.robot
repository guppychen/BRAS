*** Settings ***
Documentation    Displaying show igmp domain commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_domain_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Configure STC port with IGMP quirier and send multicast streams	Configuration successful		
    ...    3	Issue the command "show igmp domains"	Verify that the Discovery state is HAPPY		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1466      @subFeature=MVR support      @globalid=2321535      @priority=P2    @user_interface=CLI    @eut=NGPON2-4  
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Configure Video Service on UNI port Configuration successful 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Configure STC port with IGMP quirier and send multicast streams Configuration successful 
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    STEP:3 Issue the command "show igmp domains" Verify that the Discovery state is HAPPY 
    cli    eutA    show igmp domain
    check_igmp_domains    eutA    ${p_data_vlan}    mode=Proxy
    check_igmp_domains    eutA    ${mvr_vlan}    igmp_prf=${p_igmp_prf}    mode=Proxy    src_ip=@{p_proxy.ip}[0]    domain_state=READY
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1

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
