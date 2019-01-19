*** Settings ***
Documentation    Add VLAN to MVR Profile with Various Valid Range Scenarios
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Add_VLAN_to_MVR_Profile_with_Various_Valid_Range_Scenarios
    [Documentation]
    ...    1	create mvr-profiles with various range scenarios.	Success.		
    ...    2	display mvr profile with range1 only.	Success.		
    ...    3	display mvr profile with range2 only.	Success.		
    ...    4	display mvr profile with range3 only.	Success.		
    ...    5	display mvr profile with range4 only.	Success.		
    ...    6	display mvr profile with range1 &4 only.	Success.    AXOS not support		
    ...    7	display mvr profile with range1,2,3,4 only.	Success.    AXOS not support	    		 
    ...    8	display mvr profile with range4,3,2,1 only.	Success.    AXOS not support			
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1509      @subFeature=MVR support      @globalid=2321578      @priority=P2      @user_interface=CLI      @eut=NGPON2-4
    [Teardown]     case teardown
      
    log    STEP:1 create mvr-profiles with various range scenarios. Success.
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]

    log    STEP:2 display mvr profile with range1 only. Success. 
    log    STEP:3 display mvr profile with range2 only. Success. 
    log    STEP:4 display mvr profile with range3 only. Success. 
    log    STEP:5 display mvr profile with range4 only. Success. 
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    check_running_configure    eutA    mvr-profile    ${p_mvr_prf} address @{p_mvr_start_ip_list}[${index}] @{p_mvr_end_ip_list}[${index}]
    \    ...    address=@{p_mvr_start_ip_list}[${index}] @{p_mvr_end_ip_list}[${index}] @{p_video_vlan_list}[${index}]

    
*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}