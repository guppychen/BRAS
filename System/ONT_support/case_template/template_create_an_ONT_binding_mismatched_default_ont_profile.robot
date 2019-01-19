*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_create_an_ONT_binding_mismatched_default_ont_profile
    [Arguments]    ${device}    ${subscriber_point}    ${mismatch_ont_profile_id}
    [Documentation]
      
    ...    1	Create an ONT with the serial-number of discovered ONT binding mismatched default ont-profile	sucessfully		
    ...    2	Show ONT	The status is disabled		
    ...    3	Show ONT detail	display correctly		

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_mismatch_ont    ${device}    ${attribute.ont_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    STEP:1 Create an ONT with the serial-number of discovered ONT binding mismatched default ont-profile sucessfully 
    prov_ont    ${device}    ${attribute.ont_id}    ${mismatch_ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    
    log    STEP:2 Show ONT The status is disabled 
    log    show alarm active
    Wait Until Keyword Succeeds    2 min    5 s    show_alarm_mismatch    ${device}    ${attribute.ont_id}
    
    log    STEP:3 Show ONT detail display correctly 
    check_ont_detail    ${device}    ${attribute.ont_id}
    
show_alarm_mismatch
    [Arguments]    ${device}    ${ont_id}
    [Documentation]    show alarm active
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | device | device name setting in your yaml |
    ...    | ont_id | ont id |
    ...    Example:
    ...    | show_alarm_mismatch | n1 | 100 |		
    [Tags]     @author=YUE SUN  
    ${res}    cli    ${device}    show alarm active
    Should Match Regexp    ${res}   ont-prov-mismatch\\s+.*${ont_id}

template_teardown_mismatch_ont
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}