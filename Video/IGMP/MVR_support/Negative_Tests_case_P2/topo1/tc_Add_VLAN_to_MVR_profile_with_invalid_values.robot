*** Settings ***
Documentation    Add VLAN to MVR profile with invalid values
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    ${p_prov_vlan}

*** Test Cases ***
tc_Add_VLAN_to_MVR_profile_with_invalid_values
    [Documentation]
    ...    1	Add VLAN to MVR profile with invalid values: ID not present	Operations indicated as failed.		
    ...    2	Add VLAN to MVR profile with invalid values: 0	Operations indicated as failed.		
    ...    3	Add VLAN to MVR profile with invalid values: reserved VLAN	Operations indicated as failed.		
    ...    4	Add VLAN to MVR profile with invalid values: VLAN missing.	Operations indicated as failed.		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1505      @subFeature=MVR support      @globalid=2321574      @priority=P2
    ...    @user_interface=CLI      @eut=NGPON2-4    @jira=EXA-18914 fix    @jira=EXA-19055
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Add VLAN to MVR profile with invalid values: ID not present Operations indicated as failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    Run Keyword And Continue On Failure    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't provision not present vlan to mvr-profile
    Run Keyword And Continue On Failure    should contain any    ${msg}    vlan not found    Failed to add vlan to profile, please create VLAN    ignore_case=True

    log    STEP:2 Add VLAN to MVR profile with invalid values: 0 Operations indicated as failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[1]    @{p_mvr_end_ip_list}[1]    0
    Run Keyword And Continue On Failure    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't provision vlan 0 to mvr-profile
    Run Keyword And Continue On Failure    should contain    ${msg}    out of range

    log    STEP:3 Add VLAN to MVR profile with invalid values: reserved VLAN Operations indicated as failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[2]    @{p_mvr_end_ip_list}[2]    ${p_reserved_vlan}
    Run Keyword And Continue On Failure    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't provision reserved vlan to mvr-profile
    Run Keyword And Continue On Failure    should contain    ${msg}    reserved

    log    STEP:4 Add VLAN to MVR profile with invalid values: VLAN missing. Operations indicated as failed. 
    ${status}    ${msg}    Run Keyword And Ignore Error    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[3]    @{p_mvr_end_ip_list}[3]
    Run Keyword And Continue On Failure    run keyword if     '${status}'=='PASS'    Fail    Failure: shouldn't provision address without vlan to mvr-profile
    Run Keyword And Continue On Failure    should contain    ${msg}    incomplete path

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check mvr vlan not present 
    ${res}    cli    eutA    show running-config vlan ${mvr_vlan}
    Should Contain Any    ${res}    unknown    syntax error

case teardown
    [Documentation]    case teardown
    log    delete mvr profile
    Run Keyword And Ignore Error    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
