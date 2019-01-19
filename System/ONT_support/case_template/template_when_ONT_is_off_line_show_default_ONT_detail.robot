*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_when_ONT_is_off_line_show_default_ONT_detail
    [Arguments]    ${device}    ${subscriber_point} 
    [Documentation]    Description: template_when_ONT_is_off_line_show_default_ONT_detail
      
    ...    1	Show ont * detail	sucessfully		
    ...    2	Check PSE Management Ownership	No shows		

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_off_line_ont_detail    ${device}    ${attribute.ont_id} 
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    
    log    STEP:1 Show ont * detail sucessfully 
    log    off-line ont ${attribute.ont_id}
    Wait Until Keyword Succeeds    5 min    5 s    Axos Cli With Error Check    ${device}    perform ont reset ont-id ${attribute.ont_id} forced true 
    check_ont_detail    ${device}    ${attribute.ont_id}
    
    log    STEP:2 Check PSE Management Ownership No shows 
    Wait Until Keyword Succeeds    5 min    5 s    check_ont_detail    ${device}     ${attribute.ont_id}    OMCI-Only    "0.0 watts"
    
    
template_teardown_off_line_ont_detail
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    ont off-line to on-line
    Wait Until Keyword Succeeds    5 min    5 s    Axos Cli With Error Check    ${device}    perform ont reset ont-id ${ont_id} forced false    60
    Wait Until Keyword Succeeds    5 min    5 s    check_ont_status    ${device}    ${ont_id}    oper-state=present
    delete_config_object    ${device}    ont    ${ont_id}