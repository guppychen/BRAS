*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Change_voice_policy_profile_check_its_parameters
    [Documentation]
      
    ...    1	Create voice-policy-profile * vlan *(0…4095) p-bit * (0…7) dscp *(0…63)	successfully		
    ...    2	Set ont-port * voice-policy-profile name	successfully		
    ...    3	Check Voice Policy VLAN ID；p-bit & DSCP	display correctly	Check on both E7 and ONT side	
    ...    4	Set ont-port * voice-policy-profile none	successfully		
    ...    5	Check Voice Policy VLAN ID；p-bit & DSCP	Change to default on ONT side		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4329     @globalid=2531514      @priority=P1      @eut=GPON-8r2          @user_interface=CLI
    [Template]       template_change_voice_policy_profile_check_its_parameters
    eutA    ontA    subscriber_point1    ${ont_port}    ${voice_policy_profile_id}    
    ...    ${voice_policy_profile_user.vlan}    ${voice_policy_profile_user.priority}    ${voice_policy_profile_user.dscp}
    ...    ${service_vlan}    ${match_vlan}