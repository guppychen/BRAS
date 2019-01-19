*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Create_an_ONT_binding_matched_defaut_ont_profile
    [Documentation]
      
    ...    1	Create an ONT with the serial-number of discovered ONT binding matched defaut ont-profile 822G	sucessfully		
    ...    2	Show ONT	The status is enabled		
    ...    3	Show ONT detail	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4313      @globalid=2531498      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    templete_create_an_ONT_binding_matched_default_ont_profile
    eutA    subscriber_point1