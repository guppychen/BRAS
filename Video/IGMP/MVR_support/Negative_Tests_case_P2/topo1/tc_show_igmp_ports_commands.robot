*** Settings ***
Documentation    Displaying show igmp ports commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_ports_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Issue the command "show igmp ports summary"	Verify correct output is displayed		
    ...    3	Issue the command "show igmp ports vlan "	Verify correct output is displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3485      @subFeature=MVR support      @globalid=2478940
    ...      @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @jira=EXA-26420
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Configure Video Service on UNI port Configuration successful 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Issue the command "show igmp ports summary" Verify correct output is displayed
    subscriber_point_check_igmp_ports    subscriber_point1    ${p_data_vlan}    ${p_igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}    ${mvr_vlan}

    log    STEP:3 Issue the command "show igmp ports vlan " Verify correct output is displayed 
    &{dict_intf}    get_shelf_slot_interface_info    ${subscriber_port_name}    ${subscriber_port_type}
    check_igmp_ports_vlan    eutA    ${p_data_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    mode=HOST    mgmt_status=STATIC    mcast_prf=${p_mcast_prf}    oper_state=UP
    ...    mvr_prf=${p_mvr_prf}    mvr_start_ip=@{p_mvr_start_ip_list}[0]    mvr_end_ip=@{p_mvr_end_ip_list}[0]    mvr_vlan=${mvr_vlan}

    
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
