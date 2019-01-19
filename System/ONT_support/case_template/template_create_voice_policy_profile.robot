*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_create_voice_policy_profile
    [Arguments]   ${device}    ${voice_policy_profile_id}    ${vlan}    ${priority}    ${dscp}  
    [Documentation]
      
    ...    1	Create voice-policy-profile *	sucessfully		
    ...    2	Show voice-policy-profile *	The default are vlan(4094)；p-bit (6 )； dscp(EF)		
    ...    3	Modify(Set) voice-policy-profile * vlan * p-bit * dscp *	sucessfully		
    ...    4	Show voice-policy-profile *	display correctly		

    
    [Tags]     @author=YUE SUN      @user_interface=CLI    
    [Teardown]   template_teardown_create_voice_policy_profile    ${device}    ${voice_policy_profile_id}
    
    log    STEP:1 Create voice-policy-profile * sucessfully 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}
    
    log    STEP:2 Show voice-policy-profile * The default are vlan(4094)；p-bit (6 )； dscp(EF) 
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${default_voice.vlan}    ${default_voice.priority}    ${default_voice.dscp}
    
    log    STEP:3 Modify(Set) voice-policy-profile * vlan * p-bit * dscp * sucessfully 
    prov_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${vlan}    ${priority}    ${dscp}
    
    log    STEP:4 Show voice-policy-profile * display correctly
    check_voice_policy_profile    ${device}    ${voice_policy_profile_id}    ${vlan}    ${priority}    ${dscp}


template_teardown_create_voice_policy_profile
    [Arguments]    ${device}    ${voice_pro}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    voice-policy-profile    ${voice_pro}
