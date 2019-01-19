*** Settings ***
Documentation    Displaying show igmp hosts commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_hosts_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Configure STC port with IGMP quirier and send multicast streams	Configuration successful		
    ...    3	Join multicast groups from the provisioned subscribers	Verify that subscriber able to receive multicast stream		
    ...    4	Issue the command "show igmp hosts summary"	Verify correct output is displayed		
    ...    5	Issue the command "show igmp hosts vlan "	Verify correct output is displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3483      @subFeature=MVR support      @globalid=2478579      @priority=P2    @user_interface=CLI    @eut=NGPON2-4  
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

    log    STEP:3 Join multicast groups from the provisioned subscribers Verify that subscriber able to receive multicast stream 
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    tg control igmp    tg1    igmp_host1    join

    log    STEP:4 Issue the command "show igmp hosts summary" Verify correct output is displayed
    subscriber_point_check_igmp_hosts    subscriber_point1    ${p_data_vlan}    ${p_igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}    ${mvr_vlan}

    log    STEP:5 Issue the command "show igmp hosts vlan " Verify correct output is displayed
    log    check for svlan
    &{dict_intf}    get_shelf_slot_interface_info    ${subscriber_port_name}    ${subscriber_port_type}
    check_igmp_hosts_vlan    eutA    ${p_data_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    mcast_prf=${p_mcast_prf}    active_stream=${p_igmp_group_session_num}    stream_limit=${p_mcast_max_stream}
    ...    mgmt_status=STATIC    querier_status=Querier

    log    check for mvr vlan
    ${pon_port}    Run Keyword If    "ont_port"=="${service_model.subscriber_point1.type}"    subscriber_point_get_pon_port_name    subscriber_point1
    &{dict_intf}    Run Keyword If    "ont_port"=="${service_model.subscriber_point1.type}"    get_shelf_slot_interface_info    ${pon_port}    pon
    ...    ELSE    Copy Dictionary    ${dict_intf}
    check_igmp_hosts_vlan    eutA    ${mvr_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    ${p_igmp_version}    @{p_proxy.ip}[0]    active_stream=${p_igmp_group_session_num}
    ...    mgmt_status=STATIC    oper_state=UP    querier_status=Querier
    
    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1

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