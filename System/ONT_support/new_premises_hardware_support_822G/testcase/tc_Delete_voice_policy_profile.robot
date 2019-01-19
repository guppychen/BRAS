*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Delete_voice_policy_profile
    [Documentation]
      
    ...    1	Create voice-policy-profile *	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Delete voice-policy-profile *	rejected		
    ...    4	Set ont-port * voice-policy-profile none	successfully		
    ...    5	Delete voice-policy-profile *	successfully		
    ...    6	Show ont-port * voice-policy-profile	None		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4328    @globalid=2531513      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_delete_voice_policy_profile
    eutA    subscriber_point1    ${voice_policy_profile_id}
    