*** Settings ***
Documentation     MVR Profile Mismatch 
Resource          ./base.robot


*** Variables ***
${mvr_prf_new}    auto_new_mvr_prf
${mcast_prf_new}    auto_new_mcast_prf
${mvr_vlan1}    @{p_video_vlan_list}[0]
${mvr_vlan2}    @{p_video_vlan_list}[1]


*** Test Cases ***
tc_MVR_Profile_Mismatch
    [Documentation]    1	Provision two mcast-profiles with each referencing a unique MVR VLAN and same range. IGMP Proxy mode is used. 			
    ...    2	Create service on ONT interface A with the first mcast-profile. 			
    ...    3	Attempt to create the same service on ONT interface B with a the second mcast-profile.	Provisioning second access interface is successful.
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1540    @globalid=2321609    @priority=P1    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision two mcast-profiles with each referencing a unique MVR VLAN and same range. IGMP Proxy mode is used.
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan1}
    prov_mvr_profile    eutA    ${mvr_prf_new}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan2}
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    prov_multicast_profile    eutA    ${mcast_prf_new}    ${mvr_prf_new}    ${p_mcast_max_stream}

    log    STEP:2 Create service on ONT interface A with the first mcast-profile.
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Attempt to create the same service on ONT interface B with a the second mcast-profile. Provisioning second access interface is successful.
    &{dict_prf}    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${mcast_prf_new}
    set test variable    ${t_policy_map}    &{dict_prf}[policymap]

*** Keywords ***
case setup
    [Documentation]    case setup
    log    subscriber side provision
    subscriber_point_prov    subscriber_point2

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc_user_defined    subscriber_point2    ${p_data_vlan}    ${t_policy_map}    ${mcast_prf_new}
    # subscriber_point_dprov    subscriber_point2
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    delete_config_object    eutA    multicast-profile    ${mcast_prf_new}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    delete_config_object    eutA    mvr-profile    ${mvr_prf_new}
