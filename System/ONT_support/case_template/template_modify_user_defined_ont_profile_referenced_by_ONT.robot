*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_modify_user_defined_ont_profile_referenced_by_ONT
    [Arguments]    ${device}    ${subscriber_point}    ${user_ont_profile}    
    [Documentation]
      
    ...    1	Create an user-defined ont-profile	sucessfully		
    ...    2	Creat an ONT with the serial-number of discovered ONT binding matched user-defined ont-profile	sucessfully		
    ...    3	Show ONT	The status is enabled		
    ...    4	Modify user-defined ont-profile covering each parameter except name	rejected		
    ...    5	Modify user-defined ont-profile by name	sucessfully		
    ...    6	Show ONT detail	display correctly		

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_modify_user_ont    ${device}    ${attribute.ont_id}    ${user_ont_profile}
     
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute} 
    
    log    STEP:1 Create an user-defined ont-profile sucessfully 
    prov_ont_profile_with_port    ${device}    ${user_ont_profile}    ${attribute.port_info.ge}
    
    log    STEP:2 Creat an ONT with the serial-number of discovered ONT binding matched user-defined ont-profile sucessfully 
    prov_ont    ${device}    ${attribute.ont_id}    ${user_ont_profile}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    
    log    STEP:3 Show ONT The status is enabled 
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_status    ${device}    ${attribute.ont_id}    oper-state=present
    
    log    STEP:4 Modify user-defined ont-profile covering each parameter except name rejected 
    dprov_object_invaild    ${device}    ont-profile    ${user_ont_profile}    interface    ${attribute.interface_type}    g${attribute.port_info.ge}
    
    log    STEP:5 Modify user-defined ont-profile by name sucessfully
    log    STEP:6 Show ONT detail display correctly 
    check_ont_detail    ${device}    ${attribute.ont_id}
    

template_teardown_modify_user_ont
    [Arguments]    ${device}    ${ont_id}    ${profile_id}
    [Documentation] 
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}
    delete_config_object    ${device}    ont-profile    ${profile_id}
