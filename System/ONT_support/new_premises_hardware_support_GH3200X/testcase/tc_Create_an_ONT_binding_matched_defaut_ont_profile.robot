*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Create_an_ONT_binding_matched_default_ont_profile
    [Documentation]
      
    ...    1	Create an ONT with the serial-number of discovered ONT binding matched default ont-profile GH3200X	sucessfully		
    ...    2	Show ONT	The status is enabled		
    ...    3	Show ONT detail	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4709      @globalid=2533439      @priority=P1      @eut=NGPON2-4          @user_interface=CLI       
    [Template]    templete_create_an_ONT_binding_matched_default_ont_profile
    eutA    subscriber_point1