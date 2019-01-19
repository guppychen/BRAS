*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_modify_PoE_admin_status
    [Arguments]    ${device}    ${uart}    ${subscriber_point}    ${misc_poe_table}    ${uni_port}
    [Documentation]
      
    ...    1	Set ont-port * poe-admin-status enabled	successfully		
    ...    2	Check the PoE admin Status	The status is enabled	Check on both E7 and ONT side	
    ...    3	Set ont-port * poe-admin-status disabled	successfully		
    ...    4	Check the PoE admin Status	The status is disabled	Check on both E7 and ONT side	

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_modify_poe_admin    ${device}    ${attribute.ont_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}  
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:1 Set ont-port * poe-admin-status enabled successfully 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    poe-admin-state    ENABLED
    
    log    STEP:2 Check the PoE admin Status The status is enabled Check on both E7 and ONT side 
    log    check on E7 side
    check_running_configure    ${device}    interface    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    |    details    poe-admin-state=ENABLED
    log    check on ONT side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_poe    ${uart}    ${misc_poe_table}    poe_enable    ${uni_port}    1 
    
    log    STEP:3 Set ont-port * poe-admin-status disabled successfully 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    poe-admin-state    DISABLED
    
    log    STEP:4 Check the PoE admin Status The status is disabled Check on both E7 and ONT side 
    log    check on E7 side
    check_running_configure    ${device}    interface    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    |    details    poe-admin-state=DISABLED
    log    check on ONT side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_poe    ${uart}    ${misc_poe_table}    poe_enable    ${uni_port}    0

    
template_teardown_modify_poe_admin
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}