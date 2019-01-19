*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_modify_PoE_Priority
    [Arguments]    ${device}    ${uart}    ${subscriber_point}    ${misc_poe_table}    ${uni_port}    ${poe_priority}    ${poe_priority_num}
    [Documentation]
      
    ...    1	Set ont-port * poe-priority x；The available values are 3: low 2:medium（default） 1: high	successfully		
    ...    2	Check PoE Priority	display correctly	Check on both E7 and ONT side	

    
    [Tags]     @author=YUE SUN    @user_interface=CLI    
    [Teardown]     template_teardown_poe_priority    ${device}    ${attribute.ont_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  

    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:1 Set ont-port * poe-priority x；The available values are 3: low 2:medium（default） 1: high successfully 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    poe-priority    ${poe_priority}        
    
    log    STEP:2 Check PoE Priority display correctly Check on both E7 and ONT side 
    log    check on E7 side
    Wait Until Keyword Succeeds    2 min    5 s    check_running_configure    ${device}    interface    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    |    details    poe-priority=${poe_priority}
    log    check on ont side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_poe    ${uart}    ${misc_poe_table}    priority    ${uni_port}    ${poe_priority_num}
    
    
template_teardown_poe_priority
    [Arguments]    ${device}    ${ont_id}
    [Documentation] 
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}