*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Create_voice_policy_profile
    [Documentation]
      
    ...    1	Create voice-policy-profile *	sucessfully		
    ...    2	Show voice-policy-profile *	The default are vlan(4094)；p-bit (6 )； dscp(EF)		
    ...    3	Modify(Set) voice-policy-profile * vlan * p-bit * dscp *	sucessfully		
    ...    4	Show voice-policy-profile *	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4657      @globalid=2533383      @priority=P1      @eut=GPON-8r2          @user_interface=CLI 
    [Template]    template_create_voice_policy_profile
    eutA    ${voice_policy_profile_id}    ${voice_policy_profile_user.vlan}    
    ...    ${voice_policy_profile_user.priority}    ${voice_policy_profile_user.dscp}
    