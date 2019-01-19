*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_modify_PoE_High_Power_Mode
    [Arguments]    ${device}    ${subscriber_point}
    [Documentation]
      
    ...    1	Set ont-port * poe-high-power-mode；The available values are 0: disabled 1: enabled	successfully		
    ...    2	Check Modify PoE High Power Mode	display correctly	Check on both E7 and ONT side	
    ...    
    ...    Cannot check on ont side, PSE Management Ownership not exit on ont cli

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_poe_power    ${device}    ${attribute.ont_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  

    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:1 Set ont-port * poe-high-power-mode；The available values are 0: disabled 1: enabled successfully 
    prov_ont_parameter    ${device}    ${attribute.ont_id}    poe-high-power-mode
    
    log    STEP:2 Check Modify PoE High Power Mode display correctly Check on both E7 and ONT side 
    ${res}    check_running_configure    ${device}    ont    ${attribute.ont_id}    |    details
    Should Not Contain    ${res}    no poe-high-power-mode    


template_teardown_poe_power
    [Arguments]    ${device}    ${ont_id}
    [Documentation] 
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}