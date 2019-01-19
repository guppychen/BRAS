*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_when_voice_policy_profile_is_none_modify_its_parameters
    [Arguments]    ${device}    ${uart}    ${subscriber_point}    ${port_num}    ${voice_policy_profile_id}        
    ...    ${vlan}    ${priority}    ${dscp}
    [Documentation]
      
    ...    1	Create voice-policy-profile *	successfully		
    ...    2	Set ont-port * voice-policy-profile none	display correctly	Check on both E7 and ONT side	
    ...    3	Modify Voice Policy VLAN ID	successfully but ineffective on ONT side		
    ...    4	Modify p-bit(VLAN Priority）	successfully but ineffective on ONT side		
    ...    5	Modify DSCP	successfully but ineffective on ONT side		

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_modify_none_voice    ${device}    ${attribute.ont_id}    ${voice_policy_profile_id}
      
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
      
    log    STEP:1 Create voice-policy-profile * successfully 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${default_voice.vlan}    ${default_voice.priority}    ${default_voice.dscp}
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:2 Set ont-port * voice-policy-profile none display correctly Check on both E7 and ONT side 
    log    check on E7 side
    ${res}    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    should contain    ${res}    No entries found
    log    check on ont side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${default_ont_voice.vlan}    ${default_ont_voice.priority}    ${default_ont_voice.dscp}
    
    log    STEP:3 Modify Voice Policy VLAN ID successfully but ineffective on ONT side 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}    vlan=${vlan}
    log    check on E7 side
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    vlan=${vlan}
    log    check on ont side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${default_ont_voice.vlan}    ${default_ont_voice.priority}    ${default_ont_voice.dscp}
    
    log    STEP:4 Modify p-bit(VLAN Priority） successfully but ineffective on ONT side 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}    p_bit=${priority}
    log    check on E7 side
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    p_bit=${priority}
    log    check on ont side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${default_ont_voice.vlan}    ${default_ont_voice.priority}    ${default_ont_voice.dscp}
    
    log    STEP:5 Modify DSCP successfully but ineffective on ONT side 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}    dscp=${dscp}
    log    check on E7 side
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    dscp=${dscp}
    log    check on ont side
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_lldp    ${uart}    ${port_num}    ${default_ont_voice.vlan}    ${default_ont_voice.priority}    ${default_ont_voice.dscp}
    
    
template_teardown_modify_none_voice
    [Arguments]    ${device}    ${ont_id}    ${voice_pro}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}
    delete_config_object    ${device}    voice-policy-profile    ${voice_pro}
    
    