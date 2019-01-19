*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_When_voice_policy_profile_is_not_none_check_the_logic_relationships_among_its_parameters
    [Documentation]
      
    ...    1	Create voice-policy-profile * vlan untagged(4096) p-bit * (0…7) dscp *(0…63)	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Check Voice Policy VLAN ID；p-bit & DSCP	Vlan_ID (ignore) ；p-bit(ignore)；DSCP = DSCP		
    ...    4	Set voice-policy-profile * vlan *(0…4095) p-bit * (0…7) dscp *(0…63)	successfully	Check on both E7 and ONT side	
    ...    5	Check Voice Policy VLAN ID；p-bit & DSCP	Vlan_ID = VlanID ；p-bit = p-bit；DSCP = DSCP		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4326      @globalid=2531511      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]     template_when_voice_policy_profile_is_not_none_check_the_logic_relationships_among_its_parameters
    eutA    ontA    subscriber_point1    ${ont_port}    ${voice_policy_profile_id}    
    ...    ${voice_policy_profile_user.vlan}    ${voice_policy_profile_user.priority}    ${voice_policy_profile_user.dscp}
    ...    ${service_vlan}    ${match_vlan}
