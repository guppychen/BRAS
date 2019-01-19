*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***    
tc_Modify_default_ont_profile
    [Documentation]
      
    ...    1	Modify each parameter of ont-profile GH3200X	rejected		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4700      @globalid=2533430      @priority=P1      @eut=NGPON2-4       
    [Template]    template_modify_default_ont_profile
    eutA    subscriber_point1    ${status_disabled}

