*** Settings ***
Documentation    Displaying show igmp routers commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${router_port}    ${service_model.service_point1.member.interface1}


*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_routers_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Configure STC port with IGMP quirier and send multicast streams	Configuration successful		
    ...    3	Issue the command "show igmp routers summary"	Verify correct output is displayed		
    ...    4	Issue the command "show igmp routers vlan "	Verify correct output is displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3486      @subFeature=MVR support      @globalid=2478941      @priority=P2    @user_interface=CLI    @eut=NGPON2-4    
    [Setup]     case setup
    [Teardown]     case teardown
    
    log    STEP:1 Configure Video Service on UNI port Configuration successful 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Configure STC port with IGMP quirier and send multicast streams Configuration successful 
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start

    log    STEP:3 Issue the command "show igmp routers summary" Verify correct output is displayed 
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}  

    log    STEP:4 Issue the command "show igmp routers vlan " Verify correct output is displayed
    &{dict_intf}    get_shelf_slot_interface_info    ${router_port}    ${service_model.service_point1.type}
    check_igmp_routers    eutA    vlan ${mvr_vlan}    ${mvr_vlan}    &{dict_intf}[port]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${p_igmp_version}

    
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