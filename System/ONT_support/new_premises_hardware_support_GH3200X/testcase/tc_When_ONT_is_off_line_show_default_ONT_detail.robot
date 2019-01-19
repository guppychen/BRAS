*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_When_ONT_is_off_line_show_default_ONT_detail
    [Documentation]
      
    ...    1	Show ont * detail	sucessfully		
    ...    2	Check PSE Management Ownership	No shows		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4710      @globalid=2533440      @priority=P1      @eut=NGPON2-4          @user_interface=CLI     
    [Template]    template_when_ONT_is_off_line_show_default_ONT_detail
    eutA    subscriber_point1

    
