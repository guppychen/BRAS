*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_show_default_ont_profile
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]
    ...    1	Show ont-profile	                    display ont-profile and its parameters correctly in the list		
    ...    2	Show ont-profile <ont_type>     	    display correctly		
    ...    3	Show ont-profile <ont_type> detail  	display correctly		
    [Tags]      @author=YUE SUN         @user_interface=CLI    
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    STEP:1 Show ont-profile display ont-profile and its parameters correctly in the list 
    check_ont_profile_parameter    ${device}    ${attribute.ont_profile_id}     ${attribute.port_info.ge}
    ...    ${attribute.port_info.xe}    ${attribute.port_info.pots}    
    ...    ${attribute.port_info.ua}    ${attribute.port_info.rf}    
    ...    ${attribute.port_info.rg}    ${attribute.port_info.fb}
    ...    ${attribute.port_info.eth_role}    ${attribute.port_info.eth_alarm} 

    log    STEP:2 Show ont-profile ont-profile display correctly 
    check_running_configure    ${device}    ont-profile    ont-profile=${attribute.ont_profile_id}
    
    log    STEP:3 Show ont-profile ont-profile detail display correctly 
    check_running_configure    ${device}    ont-profile    ${attribute.ont_profile_id}    |    details