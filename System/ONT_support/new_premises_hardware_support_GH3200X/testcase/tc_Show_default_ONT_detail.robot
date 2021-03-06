*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Show_default_ONT_detail
    [Documentation]
      
    ...    1	Show ont * detail	sucessfully		
    ...    2	Check PSE Management Ownership	The default is 0:omci only		
    ...    3	Check PSE Max Power Budget；PSE Available Power Budget；PSE Aggregate Output Power	The default of PSE Max Power Budget is 30；PSE Aggregate Output Power = 0 & PSE Available Power Budget = 30 or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4688      @globalid=2533418      @priority=P1      @eut=NGPON2-4          @user_interface=CLI        
    [Template]    template_show_default_ONT_detail    
    eutA    subscriber_point1
