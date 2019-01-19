*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_voice_policy_profile
    [Documentation]
      
    ...    1	Create voice-policy-profile *	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Check Voice Policy Profile	display voice-policy-profile name		
    ...    4	Set ont-port * voice-policy-profile none	successfully		
    ...    5	Check Voice Policy Profile	display as none		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4642      @globalid=2533368      @priority=P1      @eut=GPON-8r2          @user_interface=CLI      
    [Template]    template_modify_voice_policy_profile
    eutA    ontA    subscriber_point1    ${voice_policy_profile_id}
    ...    ${ont_port}    ${voice_policy_profile_user.vlan}    ${voice_policy_profile_user.priority}    ${voice_policy_profile_user.dscp}
    ...    ${service_vlan}    ${match_vlan}