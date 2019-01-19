*** Settings ***
Documentation    Max MVR Profiles VLANs & Ranges Plus Add Service to ONT
Resource     ./base.robot

*** Variables ***
${start_idx}    1
${end_idx}    10

*** Test Cases ***
tc_Max_MVR_Profiles_VLANs_Ranges_Plus_Add_Service_to_ONT
    [Documentation]
    ...    1	Create max number of MVR Profiles with max VLANs and max ranges.			
    ...    2	Add video service to an access interface.			
    ...    3	Display all MVR profiles	All provisioning indicated as successful. All provisioned values can be displayed		
    ...    4	Display MVR profiles individually.	All provisioning indicated as successful. All provisioned values can be displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1516      @subFeature=MVR support      @globalid=2321585      @priority=P2      @user_interface=CLI      @eut=NGPON2-4 
    [Teardown]     case teardown
      
    log    STEP:1 Create max number of MVR Profiles with max VLANs and max ranges. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    create_mvr_prf_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    ${start_idx}    ${end_idx}

    log    STEP:2 Add video service to an access interface. 
    prov_multicast_profile    eutA    ${p_mcast_prf}    auto_mvr_prf_${p_max_mvr_prf_num}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:3 Display all MVR profiles All provisioning indicated as successful. All provisioned values can be displayed
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    check_mvr_prf_config_with_max_vlan    eutA    ${EMPTY}    vlan_prefix=${p_prov_vlan_prefix}${index}    mc_network_prefix=225.${index}    start_idx=${start_idx}    end_idx=${end_idx}

    log    STEP:4 Display MVR profiles individually. All provisioning indicated as successful. All provisioned values can be displayed 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    check_mvr_prf_config_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    ${start_idx}    ${end_idx}

    
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr config
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    \    delete_all_vlan_for_one_mvr_prf    eutA    ${p_prov_vlan_prefix}${index}
