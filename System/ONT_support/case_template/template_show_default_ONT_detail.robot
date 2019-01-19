*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_show_default_ONT_detail
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]    
      
    ...    1	Show ont * detail	sucessfully		
    ...    2	Check PSE Management Ownership	The default is 0:omci only	Check on both E7 and ONT side	
    ...    3	Check PSE Max Power Budget；PSE Available Power Budget；PSE Aggregate Output Power	The default of PSE Max Power Budget is 30；PSE Aggregate Output Power = 0 & PSE Available Power Budget = 30 or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0	Check on both E7 and ONT side
    ...    
    ...    	Cannot check on ont side, PSE Management Ownership not exit on ont cli

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_show_ont    ${device}    ${attribute.ont_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  

    log    STEP:1 Show ont * detail sucessfully 
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    check_ont_detail    ${device}    ${attribute.ont_id}    
    
    Return from keyword if     '${attribute.pse}'=='false'
    log    STEP:2 Check PSE Management Ownership The default is 0:omci only Check on both E7 and ONT side 
    log    check on E7 side
    check_ont_detail    ${device}    ${attribute.ont_id}    OMCI-Only
   
    log    STEP:3 Check PSE Max Power Budget；PSE Available Power Budget；PSE Aggregate Output Power The default of PSE Max Power Budget is 30；PSE Aggregate Output Power = 0 & PSE Available Power Budget = 30 or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0 Check on both E7 and ONT side 
    log    check on E7 side
    check_ont_detail    ${device}    ${attribute.ont_id}    OMCI-Only     "30.0 watts"    "0.0 watts" 
    
template_teardown_show_ont
    [Arguments]    ${device}    ${ont_id}
    [Documentation]  
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}

