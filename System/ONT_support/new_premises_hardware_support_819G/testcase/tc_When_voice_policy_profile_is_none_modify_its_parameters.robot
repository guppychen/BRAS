*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_When_voice_policy_profile_is_none_modify_its_parameters
    [Documentation]
      
    ...    1	Create voice-policy-profile *	successfully		
    ...    2	Set ont-port * voice-policy-profile none	display correctly		
    ...    3	Modify Voice Policy VLAN ID	successfully but ineffective on ONT side		
    ...    4	Modify p-bit(VLAN Priority）	successfully but ineffective on ONT side		
    ...    5	Modify DSCP	successfully but ineffective on ONT side		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4648      @globalid=2533374      @priority=P1      @eut=GPON-8r2          @user_interface=CLI      
    [Template]    template_when_voice_policy_profile_is_none_modify_its_parameters
    eutA    ontA    subscriber_point1    ${ont_port}    ${voice_policy_profile_id}    
    ...    ${voice_policy_profile_user.vlan}    ${voice_policy_profile_user.priority}    ${voice_policy_profile_user.dscp}
