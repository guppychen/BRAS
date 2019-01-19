*** Settings ***
Documentation     Calix Video Service shall support retrieval of MVR configuration on a per subscriber port basis
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}

*** Test Cases ***
tc_Layer3_Applications_Video_Displaying_MVR_config
    [Documentation]    1	Configure an MVR profile	MVR profile is created		
    ...    2	Configure a multicast profile and add the MVR profile 	Multicast profile created with the MVR profile		
    ...    3	Create a Uni service and attach the Multicast profile which has the MVR profile	Uni service should be created with Multicast and MVR profile		
    ...    4	Issue a show command on a subscriber port to view the video configuration of the subscriber which should include the Multicast profile and MVR configuration	MVR configuration for the subscriber is displayed
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1445    @globalid=2321513    @priority=P2    @user_interface=CLI    @eut=NGPON2-4    @jira=EXA-26420
    [Teardown]   case teardown
    log    STEP:1 Configure an MVR profile MVR profile is created
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan}

    log    STEP:2 Configure a multicast profile and add the MVR profile Multicast profile created with the MVR profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}
    check_running_configure    eutA    multicast-profile    ${p_mcast_prf}    mvr-profile=${p_mvr_prf}

    log    STEP:3 Create a Uni service and attach the Multicast profile which has the MVR profile Uni service should be created with Multicast and MVR profile
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:4 Issue a show command on a subscriber port to view the video configuration of the subscriber which should include the Multicast profile and MVR configuration MVR configuration for the subscriber is displayed
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp multicast-profile=${p_mcast_prf}
    subscriber_point_check_igmp_ports    subscriber_point1    ${p_data_vlan}    ${p_igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}    ${mvr_vlan}

    log    check igmp port vlan ${p_data_vlan} with mvr config
    &{dict_intf}    get_shelf_slot_interface_info    ${subscriber_port_name}    ${subscriber_port_type}
    check_igmp_ports_vlan    eutA    ${p_data_vlan}    &{dict_intf}[port]    &{dict_intf}[shelf]    &{dict_intf}[slot]
    ...    src_ip=0.0.0.0    mode=HOST    mgmt_status=STATIC    oper_state=UP    mcast_prf=${p_mcast_prf}
    ...    mvr_prf=${p_mvr_prf}    mvr_start_ip=@{p_mvr_start_ip_list}[0]    mvr_end_ip=@{p_mvr_end_ip_list}[0]    mvr_vlan=${mvr_vlan}

*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
