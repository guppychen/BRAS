*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_delete_voice_policy_profile
    [Arguments]    ${device}    ${subscriber_point}     ${voice_policy_profile_id}
    [Documentation]
      
    ...    1	Create voice-policy-profile *	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Delete voice-policy-profile *	rejected		
    ...    4	Set ont-port * voice-policy-profile none	successfully		
    ...    5	Delete voice-policy-profile *	successfully		
    ...    6	Show ont-port * voice-policy-profile	None		

    [Teardown]    template_teardown_delete_voice    ${device}    ${attribute.ont_id}    ${voice_policy_profile_id}    ${subscriber_point}    
    ...    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}
    [Tags]     @author=YUE SUN    @user_interface=CLI    
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    STEP:1 Create voice-policy-profile * successfully 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:2 Set ont-port * voice-policy-profile name successfully
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile    ${voice_policy_profile_id}
    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    ...    voice-policy-profile=${voice_policy_profile_id}

    log    STEP:3 Delete voice-policy-profile * rejected 
    dprov_object_invaild    ${device}    voice-policy-profile    ${voice_policy_profile_id}
    
    log    STEP:4 Set ont-port * voice-policy-profile none successfully 
    dprov_port_voice_policy_profile    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}
    
    log    STEP:5 Delete voice-policy-profile * successfully 
    delete_config_object    ${device}    voice-policy-profile    ${voice_policy_profile_id}
    
    log    STEP:6 Show ont-port * voice-policy-profile None 
    ${res}    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    should contain    ${res}    No entries found
    
    
template_teardown_delete_voice
    [Arguments]    ${device}    ${ont_id}    ${voice_pro}    ${subscriber_point}    ${interface_type}    ${interface_name}
    [Documentation] 
    log    template teardown
    run keyword and ignore error    dprov_port_voice_policy_profile    ${device}    ${interface_type}    ${interface_name}
    run keyword and ignore error    delete_config_object    ${device}    voice-policy-profile    ${voice_pro}
    ${res}    check_running_config_interface    ${device}    ${interface_type}    ${interface_name}    voice-policy-profile
    should contain    ${res}    No entries found
    delete_config_object    ${device}    ont    ${ont_id}
