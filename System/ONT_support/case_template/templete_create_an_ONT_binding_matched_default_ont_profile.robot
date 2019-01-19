*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
templete_create_an_ONT_binding_matched_default_ont_profile
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]
      
    ...    1	Create an ONT with the serial-number of discovered ONT binding matched defaut ont-profile 	sucessfully		
    ...    2	Show ONT	The status is enabled		
    ...    3	Show ONT detail	display correctly		

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_match_ont    ${device}    ${attribute.ont_id}
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  
    
    log    STEP:1 Create an ONT with the serial-number of discovered ONT binding matched defaut ont-profile sucessfully 
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    
    log    STEP:2 Show ONT The status is enabled 
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_status    ${device}    ${attribute.ont_id}    oper-state=present
    
    log    STEP:3 Show ONT detail display correctly 
    check_ont_detail    ${device}    ${attribute.ont_id}


    
template_teardown_match_ont
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}
