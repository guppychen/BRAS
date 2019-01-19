*** Settings ***
Documentation    Add/Remove/Re-Add MVR Profile VLAN
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Add_Remove_Re_Add_MVR_Profile_VLAN
    [Documentation]
    ...    1	Create an MVR profile. Add VLAN to MVR profile.	Display MVR profile. All provisioning is indicated as successful. The VLAN is displayed.		
    ...    2	Remove VLAN from MVR Profile.	Display MVR profile. All provisioning is indicated as successful. The VLAN is not displayed.		
    ...    3	Re-add VLAN to MVR profile.	Display MVR profile. All provisioning is indicated as successful. The VLAN is displayed.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1507      @subFeature=MVR support      @globalid=2321576      @priority=P2    @user_interface=CLI      @eut=NGPON2-4    
    [Teardown]     case teardown
      
    log    STEP:1 Create an MVR profile. Add VLAN to MVR profile. Display MVR profile. All provisioning is indicated as successful. The VLAN is displayed. 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan}

    log    STEP:2 Remove VLAN from MVR Profile. Display MVR profile. All provisioning is indicated as successful. The VLAN is not displayed. 
    dprov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan}    contain=no

    log    STEP:3 Re-add VLAN to MVR profile. Display MVR profile. All provisioning is indicated as successful. The VLAN is displayed.
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=@{p_mvr_start_ip_list}[0] @{p_mvr_end_ip_list}[0] ${mvr_vlan} 

    
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}