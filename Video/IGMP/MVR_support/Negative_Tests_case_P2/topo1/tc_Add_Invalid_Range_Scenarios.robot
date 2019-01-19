*** Settings ***
Documentation    Add Invalid Range Scenarios
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]
${mvr_vlan2}    @{p_video_vlan_list}[1]
${mcast_net}    225.1.1
${mcast_net2}    225.2.1
${start_idx}    10
${end_idx}    20
${err_idx}    300

*** Test Cases ***
tc_Add_Invalid_Range_Scenarios
    [Documentation]
    ...    1	Create an MVR profile. Attempt to add VLAN to MVR profile using invalid range(s) scenarios.			
    ...    2	Add second VLAN overlapping range at start range;	All operation indicated as failed. Address overlap error messages indicate errored ranges.		
    ...    3	Add second VLAN overlapping range at end range	All operation indicated as failed. Address overlap error messages indicate errored ranges.		
    ...    4	Add second VLAN overlapping range at entire range;	All operation indicated as failed. Address overlap error messages indicate errored ranges.		
    ...    5	Add VLAN with over lapping ranges within add command ranges (overlap at start range),	All operation indicated as failed. Address overlap error messages indicate errored ranges.	(AXOS NOT support to configure more than one range in one command)	
    ...    6	Add VLAN with over lapping ranges within add command ranges (overlap at end range),	All operation indicated as failed. Address overlap error messages indicate errored ranges.	(AXOS NOT support to configure more than one range in one command)	
    ...    7	Add VLAN with over lapping ranges within add command ranges (overlap at entire range),	All operation indicated as failed. Address overlap error messages indicate errored ranges.	(AXOS NOT support to configure more than one range in one command)	
    ...    8	Add VLAN with invalid Class D addresses (non start class-D).	All operation indicated as failed.		
    ...    9	Add VLAN with invalid Class D addresses (non end class-D).	All operation indicated as failed.		
    ...    10	Add VLAN with invalid Class D addresses (end address > start address).	All operation indicated as failed.		
    ...    11	Add VLAN with invalid Class D addresses (invalid start IP address).	All operation indicated as failed.		
    ...    12	Add VLAN with invalid Class D addresses (invalid end IP address).	All operation indicated as failed.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1512      @subFeature=MVR support      @globalid=2321581      @priority=P2      @user_interface=CLI      @eut=NGPON2-4
    [Teardown]     case teardown
      
    log    STEP:1 Create an MVR profile. Attempt to add VLAN to MVR profile using invalid range(s) scenarios. 
    prov_mvr_profile    eutA    ${p_mvr_prf}    ${mcast_net}.${start_idx}    ${mcast_net}.${end_idx}    ${mvr_vlan}
    check_running_configure    eutA    mvr-profile    ${p_mvr_prf}    address=${mcast_net}.${start_idx} ${mcast_net}.${end_idx} ${mvr_vlan}
    ${start-1}    evaluate    ${start_idx}-1
    ${end+1}    evaluate    ${end_idx}+1

    log    STEP:2 Add second VLAN overlapping range at start range; All operation indicated as failed. Address overlap error messages indicate errored ranges. 
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net}.${start-1}    ${mcast_net}.${end_idx}    ${mvr_vlan2}    (Invalid range|Range is overlapped)

    log    STEP:3 Add second VLAN overlapping range at end range All operation indicated as failed. Address overlap error messages indicate errored ranges. 
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net}.${start_idx}    ${mcast_net}.${end+1}    ${mvr_vlan2}    (Invalid range|Range is overlapped)

    log    STEP:4 Add second VLAN overlapping range at entire range; All operation indicated as failed. Address overlap error messages indicate errored ranges. 
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net}.${start-1}    ${mcast_net}.${end+1}    ${mvr_vlan2}    (Invalid range|Range is overlapped)
    
    log    STEP:5-7 AXOS NOT support to configure more than one range in one command

    log    STEP:8 Add VLAN with invalid Class D addresses (non start class-D). All operation indicated as failed. 
    log    STEP:9 Add VLAN with invalid Class D addresses (non end class-D). All operation indicated as failed.
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net}.${start-1}    vlan=${mvr_vlan2}    error_msg=invalid 

    log    STEP:10 Add VLAN with invalid Class D addresses (end address > start address). All operation indicated as failed. 
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net2}.${end_idx}    ${mcast_net2}.${start_idx}    ${mvr_vlan2}    Invalid range

    log    STEP:11 Add VLAN with invalid Class D addresses (invalid start IP address). All operation indicated as failed.
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net2}.${err_idx}    ${mcast_net2}.${end_idx}    ${mvr_vlan2}    invalid value

    log    STEP:12 Add VLAN with invalid Class D addresses (invalid end IP address). All operation indicated as failed. 
    prov_mvr_invalid_range    eutA    ${p_mvr_prf}    ${mcast_net2}.${start_idx}    ${mcast_net2}.${err_idx}    ${mvr_vlan2}    invalid value

    
*** Keywords ***
prov_mvr_invalid_range
    [Arguments]    ${device}    ${mvr_prf}    ${start_ip}    ${end_ip}=${EMPTY}    ${vlan}=${EMPTY}    ${error_msg}=${EMPTY}    
    [Documentation]    prov_mvr_range_with_error_check
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    ${device}    ${mvr_prf}    ${start_ip}    ${end_ip}    ${vlan}
    Run Keyword And Continue On Failure    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't provision mvr-profile with ${error_msg}
    Run Keyword And Continue On Failure    Should Match Regexp    ${msg}    ${error_msg}
    check_running_configure    ${device}    mvr-profile    ${mvr_prf}    address=${start_ip} ${end_ip} ${vlan}    contain=no

case teardown
    [Documentation]    case teardown
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}