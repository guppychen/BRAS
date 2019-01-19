*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_PoE_High_Power_Mode
    [Documentation]
      
    ...    1	Set ont-port * poe-high-power-mode；The available values are 0: disabled 1: enabled	successfully		
    ...    2	Check Modify PoE High Power Mode	display correctly	Check on both E7 and ONT side	

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4324      @globalid=2531509      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_modify_PoE_High_Power_Mode
    eutA    subscriber_point1
