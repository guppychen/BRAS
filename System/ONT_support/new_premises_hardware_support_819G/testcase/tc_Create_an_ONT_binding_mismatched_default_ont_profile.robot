*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Create_an_ONT_binding_mismatched_default_ont_profile
    [Documentation]
      
    ...    1	Create an ONT with the serial-number of discovered ONT binding mismatched default ont-profile 819G	sucessfully	sucessfully	
    ...    2	Show ONT	The status is disabled	The status is disabled	
    ...    3	Show ONT detail	display correctly	display correctly	

        
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4653     @globalid=2533379      @priority=P1      @eut=GPON-8r2          @user_interface=CLI   
    [Template]     template_create_an_ONT_binding_mismatched_default_ont_profile
    eutA    subscriber_point1      ${mismatch_ont_profile}

