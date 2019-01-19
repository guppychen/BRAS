*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Show_default_ont_profile
    [Documentation]
      
    ...    1	Show ont-profile	display GH3200X and its parameters correctly in the list		
    ...    2	Show ont-profile GH3200X	display correctly		
    ...    3	Show ont-profile GH3200X detail	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4705      @globalid=2533435      @priority=P1      @eut=NGPON2-4          @user_interface=CLI            
    [Template]    template_show_default_ont_profile
    eutA    subscriber_point1