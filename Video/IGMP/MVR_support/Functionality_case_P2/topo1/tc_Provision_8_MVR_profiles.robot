*** Settings ***
Documentation     Provision 8 MVR Profiles with max(4) vlan and ipmc ranges(4)
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Provision_8_MVR_profiles
    [Documentation]    1	Provision max(8) mvr profiles with max(4) vlan and ipmc ranges(4).	Provision Success.		
    ...    2	Check 8 mvr-profiles exist.	Success		
    ...    3	Check each mvr-profile with max(4) vlans and each vlan with max(4) ranges.	Success
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1451    @globalid=2321519    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Provision max(8) mvr profiles with max(4) vlan and ipmc ranges(4). Provision Success.
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    create_mvr_prf_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10

    log    STEP:2 Check 8 mvr-profiles exist. Success
    log    STEP:3 Check each mvr-profile with max(4) vlans and each vlan with max(4) ranges. Success
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    check_mvr_prf_config_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10

    log    can't add more mvr profile
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    auto_mvr_prf_more
    run keyword if     '${status}'=='PASS'    Fail    Failure: Shouldn't configure MVR profile for more than max number:${p_max_mvr_prf_num} 
    should contain    ${msg}    maximum number

*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete mvr config
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_prf_num}+1
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    \    delete_all_vlan_for_one_mvr_prf    eutA    ${p_prov_vlan_prefix}${index}
