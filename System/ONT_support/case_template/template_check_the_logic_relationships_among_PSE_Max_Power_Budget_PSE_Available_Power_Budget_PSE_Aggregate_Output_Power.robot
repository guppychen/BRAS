*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_check_the_logic_relationships_among_PSE_Max_Power_Budget_PSE_Available_Power_Budget_PSE_Aggregate_Output_Power
    [Arguments]       ${device}    ${subscriber_point}    ${pse_max}
    [Documentation]
      
    ...    1	Set ont * pse-max-power-budget x；the scope is 1..90	successfully		
    ...    2	Check PSE Max Power Budget；PSE Available Power Budget & PSE Aggregate Output Power	PSE Aggregate Output Power = 0 & PSE Available Power Budget = x or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0	Check on both E7 and ONT side	
    ...    3	Set ont-port * poe-admin-status enabled	successfully		
    ...    4	Check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power	PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x	Check on both E7 and ONT side	
    ...    5	Connect an IP phone then check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power	PSE Aggregate Output Power ！= 0 and PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x	Check on both E7 and ONT side	
    ...    
    ...    Cannot check on ont side, PSE Management Ownership not exit on ont cli
    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_check_pse    ${device}    ${attribute.ont_id}
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  

    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    check_ont_detail    ${device}    ${attribute.ont_id}
      
    log    STEP:1 Set ont * pse-max-power-budget x；the scope is 1..90 successfully 
    prov_ont_parameter    ${device}    ${attribute.ont_id}    pse-max-power-budget    ${pse_max}
    
    log    STEP:2 Check PSE Max Power Budget；PSE Available Power Budget & PSE Aggregate Output Power PSE Aggregate Output Power = 0 & PSE Available Power Budget = x or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0 Check on both E7 and ONT side 
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_detail    ${device}    ${attribute.ont_id}    OMCI-Only     "${pse_max}.0 watts"    "0.0 watts
    
    log    STEP:3 Set ont-port * poe-admin-status enabled successfully 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    poe-admin-state    ENABLED
    check_running_configure    ${device}    interface    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    |    details    poe-admin-state=ENABLED
    
    log    STEP:4 Check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x Check on both E7 and ONT side     
    Wait Until Keyword Succeeds    2 min    5 s    check_pse_power_allocation    ${device}    ${attribute.ont_id}    ${pse_max}
    
    log    STEP:5 Connect an IP phone then check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power PSE Aggregate Output Power ！= 0 and PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x Check on both E7 and ONT side 
    check_pse_power_allocation    ${device}    ${attribute.ont_id}    ${pse_max}     judge

    
check_pse_power_allocation
    [Arguments]    ${device}     ${ont_id}    ${pse_max}    ${judge_condition}=${EMPTY}
    [Documentation]    check pse power allocation
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ONT name |
    ...    | pse_max | PSE Max Power Budget  |
    ...    | judge_condition | judging condition of whether pse-available-power-budget equal to 0 |
    ...    Example:
    ...    | check_pse_power_allocation | 822 | 60 |
    [Tags]    @author=YUE SUN
    ${res}    check_ont_detail    ${device}    ${ont_id}
    ${pse_max_power}    Evaluate    ${pse_max}-0.1
    ${match}    ${pse_avai}    should Match Regexp    ${res}    pse-available-power-budget\\s+\"+(\\d+\.+\\d+)\\s+watts\"
    ${match}    ${pse_agg}    should Match Regexp    ${res}    pse-agg-output-power\\s+\"+(\\d+\.+\\d+)\\s+watts\"
    run keyword if     '${judge_condition}'!='${EMPTY}'    should be true    ${pse_avai}!=0
    ${add_value}    Evaluate    ${pse_avai}+${pse_agg}
    should be true    ${add_value}==${pse_max_power}
    
template_teardown_check_pse
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}
    