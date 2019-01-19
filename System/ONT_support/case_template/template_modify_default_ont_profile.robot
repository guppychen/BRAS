*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_modify_default_ont_profile
    [Arguments]    ${device}    ${subscriber_point}    ${alarm}
    [Documentation]
 
    ...    1	Modify each parameter of ont-profile	rejected	
	   
    [Tags]     @author=YUE SUN     @user_interface=CLI  
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute} 
    
    check_running_configure    ${device}    ont-profile    ${attribute.ont_profile_id}
    log    STEP:1 Modify each parameter of default ont-profile, rejected         
    log    modify default ont-profile port role and alarm, rejected
    ${port_name}    set variable if    ${attribute.port_info.xe}!=0    x1    g1
    prov_ont_profile_interface_invalid    ${device}    ${attribute.ont_profile_id}    ${port_name}     ${attribute.interface_role}    ${alarm} 
    log    delete default port, rejected
    dprov_object_invaild    ${device}    ont-profile    ${attribute.ont_profile_id}    interface    ${attribute.interface_type}    ${port_name}    
    
    log    add over range port, rejected
    ${over_range}    Evaluate    ${attribute.port_info.ge}+1
    prov_ont_profile_interface_invalid    ${device}    ${attribute.ont_profile_id}    g${over_range} 
    
    log    check ont-profile parameter
    check_ont_profile_parameter    ${device}    ${attribute.ont_profile_id}     ${attribute.port_info.ge}
    ...    ${attribute.port_info.xe}    ${attribute.port_info.pots}    
    ...    ${attribute.port_info.ua}    ${attribute.port_info.rf}    
    ...    ${attribute.port_info.rg}    ${attribute.port_info.fb}
    ...    ${attribute.port_info.eth_role}    ${attribute.port_info.eth_alarm} 