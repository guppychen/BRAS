*** Settings ***
Documentation    Max(8) MVR Profiles + 1 and Max entries per profile 
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Max_8_MVR_Profiles_plus_1_and_Max_entries_per_profile
    [Documentation]
    ...    1	Create max number of MVR Profiles.	The max number of MVRs provisioning is indicated as successful.		
    ...    2	Create one more MVR Profiles.	The max +1 MVR profile provisioning failed.		
    ...    3	Display MVR profiles individually.	The Max MVR can be displayed.		
    ...    4	Add 8 entries for each profile.	The max number of entries provisioning is indicated as successful.		
    ...    5	Add one more entire for each profile.	The max +1 entry provisioning failed.		
    ...    6	Display MVR profiles specifically.	The Max entries can be displayed.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1517      @subFeature=MVR support      @globalid=2321586      @priority=P2      @user_interface=CLI    @eut=NGPON2-4  
    [Teardown]     case teardown
      
    log    STEP:1 Create max number of MVR Profiles. The max number of MVRs provisioning is indicated as successful. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    prov_mvr_profile    eutA    auto_mvr_prf_${index}

    log    STEP:2 Create one more MVR Profiles. The max +1 MVR profile provisioning failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    auto_mvr_prf_more
    run keyword if     '${status}'=='PASS'    Fail    Failure: Shouldn't configure MVR profile for more than max number:${p_max_mvr_prf_num} 
    should contain    ${msg}    maximum number

    log    STEP:3 Display MVR profiles individually. The Max MVR can be displayed. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    check_running_configure    eutA    mvr-profile    auto_mvr_prf_${index}    mvr-profile=auto_mvr_prf_${index}

    log    STEP:4 Add 8 entries for each profile. The max number of entries provisioning is indicated as successful. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    create_mvr_prf_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10

    log    STEP:5 Add one more entire for each profile. The max +1 entry provisioning failed. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    prov_more_entry_for_mvr_profile    eutA    auto_mvr_prf_${index}    ${mvr_vlan}    226.1.1.1    226.1.1.10

    log    STEP:6 Display MVR profiles specifically. The Max entries can be displayed. 
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    check_mvr_prf_config_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10

    
*** Keywords ***
prov_more_entry_for_mvr_profile
    [Arguments]    ${device}    ${mvr_prf}    ${vlan}    ${start_mc}    ${end_mc}
    [Documentation]    provision more entry for mvr-profile
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    ${device}    ${mvr_prf}    ${start_mc}    ${end_mc}    ${vlan}    
    run keyword if     '${status}'=='PASS'    Fail    Failure: Shouldn't configure MVR profile with more than max number(${p_max_mvr_range_per_prf}) entries
    should contain    ${msg}    Limit of ${p_max_mvr_range_per_prf} reached

case teardown
    [Documentation]    case teardown
    log    delete mvr config
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    \    delete_all_vlan_for_one_mvr_prf    eutA    ${p_prov_vlan_prefix}${index}
