*** Settings ***
Documentation     Create video service on ONT port with single vlan mvr-profile
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}


*** Test Cases ***
tc_Create_video_service_on_ONT_port_with_single_vlan_mvr_profile
    [Documentation]    1	Create mvr-profile with signal vlans	Success		
    ...    2	Add video-service to ont/dsl-port.	Success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1452    @globalid=2321520    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Create mvr-profile with signal vlans Success
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan}

    log    STEP:2 Add video-service to ont/dsl-port. Success
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    log    check video-service configuration
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp multicast-profile=${p_mcast_prf}
    subscriber_point_check_igmp_ports    subscriber_point1    ${p_data_vlan}    ${p_igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}    ${mvr_vlan}


*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}