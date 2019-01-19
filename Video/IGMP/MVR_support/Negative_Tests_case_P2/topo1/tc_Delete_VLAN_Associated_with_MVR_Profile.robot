*** Settings ***
Documentation    Delete VLAN Associated with MVR Profile 
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    ${p_prov_vlan}

*** Test Cases ***
tc_Delete_VLAN_Associated_with_MVR_Profile
    [Documentation]
    ...    1	create a mvr vlan	success		
    ...    2	create a mvr profile, add the vlan to it	success		
    ...    3	delete mvr vlan	failed		
    ...    4	remove the vlan from mvr-profile, and delete mvr-profile and vlan	success		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-1504      @subFeature=MVR support      @globalid=2321573      @priority=P2
    ...    @user_interface=CLI      @eut=NGPON2-4    @jira=EXA-18991 fix 
    [Setup]     case setup
    [Teardown]     case teardown

    log    STEP:2 create a mvr profile, add the vlan to it success
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}

    log    STEP:3 delete mvr vlan failed
    ${status}    ${msg}    Run Keyword And Ignore Error    delete_config_object    eutA    vlan    ${mvr_vlan}
    Run Keyword If     '${status}'=='PASS'    Fail    Failure: shouldn't delete vlan provision with mvr-profile
    should contain any    ${msg}    use in an MVR profile    mvr    ignore_case=True

    log    STEP:4 remove the vlan from mvr-profile, and delete mvr-profile and vlan success
    dprov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    
    log    delete vlan success
    delete_config_object    eutA    vlan    ${mvr_vlan}

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    STEP:1 create a mvr vlan success 
    prov_vlan    eutA    ${mvr_vlan}
    
case teardown
    [Documentation]    case teardown
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    log    delete mvr vlan
    Run Keyword And Ignore Error    delete_config_object    eutA    vlan    ${mvr_vlan}
    log    check mvr vlan not present 
    ${res}    cli    eutA    show running-config vlan ${mvr_vlan}
    Should Contain Any    ${res}    unknown    syntax error
    