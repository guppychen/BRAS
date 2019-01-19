*** Settings ***
Documentation    Max Multicast Profiles(32), MVR Profiles(8), VLANs(8) per Profile,or Ranges(8) per VLAN 
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Max_Multicast_Profiles_32_MVR_Profiles_8_VLANs_8_per_Profile_or_Ranges_8_per_VLAN
    [Documentation]
    ...    1	create 32 mcast-profile, 8 mvr-profile with 8 mvr-vlan	success		
    ...    2	add 8 vlan to each profile with 8 range	success		
    ...    3	show mcast-profile	All provisioned values can be displayed either on display all or display individual Mcast profiles.		
    ...    4	show mvr-profile	8 MVR profiles found.		
    ...    5	create mcast-profile and mvr-profile	both failed		
    ...    6	delete all vlan mvr-profile and mcast-profile	success		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1530      @subFeature=MVR support      @globalid=2321599      @priority=P2      @user_interface=CLI    @eut=NGPON2-4     
    [Teardown]     case teardown
      
    log    STEP:1 create 32 mcast-profile, 8 mvr-profile success
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_prf_num}
    \    prov_mvr_profile    eutA    auto_mvr_prf_${index}
    
    : FOR    ${index}    IN RANGE    0    ${p_max_mcast_prf_num}
    \    ${mvr_index}    evaluate    ${index}%${p_max_mvr_prf_num}
    \    prov_multicast_profile    eutA    auto_mcast_prf_${index}    auto_mvr_prf_${mvr_index}

    log    STEP:2 add 8 vlan to each profile with 8 range success
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_prf_num}
    \    create_mvr_prf_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10 

    log    STEP:3 show mcast-profile All provisioned values can be displayed either on display all or display individual Mcast profiles. 
    ${display_all_res}    cli    eutA    show running-config multicast-profile
    : FOR    ${index}    IN RANGE    0    ${p_max_mcast_prf_num}
    \    ${mvr_index}    evaluate    ${index}%${p_max_mvr_prf_num}
    \    check_running_configure    eutA    multicast-profile    auto_mcast_prf_${index}    mvr-profile=auto_mvr_prf_${mvr_index}
    \    Should Match Regexp    ${display_all_res}    mvr-profile\\s+auto_mvr_prf_${mvr_index}

    log    STEP:4 show mvr-profile 8 MVR profiles found. 
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_prf_num}
    \    check_mvr_prf_config_with_max_vlan    eutA    auto_mvr_prf_${index}    ${p_prov_vlan_prefix}${index}    225.${index}    1    10

    log    STEP:5 create mcast-profile and mvr-profile both failed
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_multicast_profile    eutA    auto_mcast_prf_more
    run keyword if     '${status}'=='PASS'    Fail    Failure: Shouldn't configure multicast-profile for more than max number:${p_max_mcast_prf_num} 
    should contain    ${msg}    maximum number
    
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    auto_mvr_prf_more
    run keyword if     '${status}'=='PASS'    Fail    Failure: Shouldn't configure MVR profile for more than max number:${p_max_mvr_prf_num} 
    should contain    ${msg}    maximum number

    log    STEP:6 delete all vlan mvr-profile and mcast-profile success (see teardown part)

    
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete multicast-profile config
    : FOR    ${index}    IN RANGE    0    ${p_max_mcast_prf_num}
    \    delete_config_object    eutA    multicast-profile    auto_mcast_prf_${index}
    
    log    delete mvr config
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_prf_num}
    \    delete_config_object    eutA    mvr-profile    auto_mvr_prf_${index}
    \    delete_all_vlan_for_one_mvr_prf    eutA    ${p_prov_vlan_prefix}${index}