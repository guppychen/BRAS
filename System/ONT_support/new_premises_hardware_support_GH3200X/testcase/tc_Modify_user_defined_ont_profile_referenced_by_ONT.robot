*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_user_defined_ont_profile_referenced_by_ONT
    [Documentation]
      
    ...    1	Create an user-defined ont-profile	sucessfully		
    ...    2	Creat an ONT with the serial-number of discovered ONT binding matched user-defined ont-profile	sucessfully		
    ...    3	Show ONT	The status is enabled		
    ...    4	Modify user-defined ont-profile covering each parameter except name	rejected		
    ...    5	Modify user-defined ont-profile by name	sucessfully		
    ...    6	Show ONT detail	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4706      @globalid=2533436      @priority=P1      @eut=NGPON2-4          @user_interface=CLI           
    [Template]    template_modify_user_defined_ont_profile_referenced_by_ONT
    eutA    subscriber_point1    ${user_ont_profile}
