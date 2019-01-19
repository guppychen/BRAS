*** Settings ***
Documentation     Create video service on ONT port using multiple vlan mvr-profile 
Resource          ./base.robot


*** Variables ***
${subscriber_port_type}    ${service_model.subscriber_point1.attribute.interface_type}
${subscriber_port_name}    ${service_model.subscriber_point1.name}


*** Test Cases ***
tc_Create_video_service_on_ONT_port_using_multiple_vlan_mvr_profile
    [Documentation]    1	Create mvr-profile with multiple vlans. 	Success		
    ...    2	Add voice-service to ont/dsl-port.	Success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1453    @globalid=2321521    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Create mvr-profile with multiple vlans. Success
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[${index}] @{p_mvr_end_ip_list}[${index}] @{p_video_vlan_list}[${index}]

    log    STEP:2 Add voice-service to ont/dsl-port. Success
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    log    check video-service configuration
    check_running_config_interface    eutA    ${subscriber_port_type}    ${subscriber_port_name}    igmp multicast-profile=${p_mcast_prf}
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    subscriber_point_check_igmp_ports    subscriber_point1    ${p_data_vlan}    ${p_igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}    @{p_video_vlan_list}[${index}]


*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}