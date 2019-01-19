*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_change_voice_policy_profile_check_its_parameters
    [Arguments]    ${device}    ${uart}    ${subscriber_point}     ${port_num}    ${voice_policy_profile_id}
    ...    ${vlan}    ${priority}    ${dscp}
    ...    ${service_vlan}    ${match_vlan}
    [Documentation]
    
    ...    1	Create voice-policy-profile * vlan *(0…4095) p-bit * (0…7) dscp *(0…63)	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Check Voice Policy VLAN ID；p-bit & DSCP	display correctly	Check on both E7 and ONT side	
    ...    4	Set ont-port * voice-policy-profile none	successfully		
    ...    5	Check Voice Policy VLAN ID；p-bit & DSCP	Change to default on ONT side
    
    
    [Tags]     @author=YUE SUN    @user_interface=CLI    
    [Teardown]    template_teardown_change_voice_policy_profile    ${device}    ${attribute.ont_id}    ${voice_policy_profile_id}    ${subscriber_point}
    ...    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    ${service_vlan}    ${match_vlan}
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log     provision vlan
    prov_vlan    eutA    ${service_vlan}
    
    log    STEP:1 Create voice-policy-profile * vlan *(0…4095) p-bit * (0…7) dscp *(0…63) successfully 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${vlan}    ${priority}    ${dscp}

    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    log     step1: create a class-map to match VLAN ${service_vlan} in flow 1
    log     step2: create a policy-map to bind the class-map and add c-tag
    log     step3: apply the s-tag and policy-map to the port of ont
    subscriber_point_add_svc    ${subscriber_point}      ${match_vlan}     ${service_vlan}
    
    log    STEP:2 Set ont-port * voice-policy-profile name successfully 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile    ${voice_policy_profile_id}
    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    ...    voice-policy-profile=${voice_policy_profile_id}
    
    log    STEP:3 Check Voice Policy VLAN ID；p-bit & DSCP display correctly Check on both E7 and ONT side 
    log    Check on E7 
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${vlan}    ${priority}    ${dscp}
    log    Check on ONT side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${vlan}    ${priority}    ${dscp}   
    
    log    STEP:4 Set ont-port * voice-policy-profile none successfully 
    dprov_port_voice_policy_profile    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}
    ${res}    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    should contain    ${res}    No entries found
    
    log    STEP:5 Check Voice Policy VLAN ID；p-bit & DSCP Change to default on ONT side 
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${default_ont_voice.vlan}    ${default_ont_voice.priority}    ${default_ont_voice.dscp}
    

template_teardown_change_voice_policy_profile
    [Arguments]    ${device}    ${ont_id}    ${voice_pro}    ${subscriber_point}    ${interface_type}    ${interface_name}    ${service_vlan}    ${match_vlan}
    [Documentation]
    log    template teardown
    run keyword and ignore error    dprov_port_voice_policy_profile    ${device}    ${interface_type}    ${interface_name} 
    subscriber_point_remove_svc    ${subscriber_point}      ${match_vlan}     ${service_vlan}
    delete_config_object    ${device}    ont    ${ont_id}
    delete_config_object    ${device}    voice-policy-profile    ${voice_pro}
    dprov_vlan_timeout    ${device}    ${service_vlan}
    