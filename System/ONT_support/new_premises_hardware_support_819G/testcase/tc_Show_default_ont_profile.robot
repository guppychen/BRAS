*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Show_default_ont_profile
    [Documentation]
      
    ...    1	Show ont-profile	display 819G and its parameters correctly in the list		
    ...    2	Show ont-profile 819G	display correctly		
    ...    3	Show ont-profile 819G detail	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4655      @globalid=2533381      @priority=P1      @eut=GPON-8r2          @user_interface=CLI     
    [Template]    template_show_default_ont_profile
    eutA    subscriber_point1