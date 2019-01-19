*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
 

*** Test Cases ***
tc_Check_the_logic_relationships_among_PSE_Max_Power_Budget_PSE_Available_Power_Budget_PSE_Aggregate_Output_Power
    [Documentation]
      
    ...    1	Set ont * pse-max-power-budget x；the scope is 1..90	successfully		
    ...    2	Check PSE Max Power Budget；PSE Available Power Budget & PSE Aggregate Output Power	PSE Aggregate Output Power = 0 & PSE Available Power Budget = x or PSE Aggregate Output Power = 0 & PSE Available Power Budget = 0	Check on both E7 and ONT side	
    ...    3	Set ont-port * poe-admin-status enabled	successfully		
    ...    4	Check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power	PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x	Check on both E7 and ONT side	
    ...    5	Connect an IP phone then check PSE Max Power Budget； PSE Available Power Budget & PSE Aggregate Output Power	PSE Aggregate Output Power ！= 0 and PSE Available Power Budget + PSE Aggregate Output Power = PSE Max Power Budget = x	Check on both E7 and ONT side	

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4321      @globalid=2531506      @priority=P1      @eut=GPON-8r2          @user_interface=CLI    
    [Template]    template_check_the_logic_relationships_among_PSE_Max_Power_Budget_PSE_Available_Power_Budget_PSE_Aggregate_Output_Power
    eutA    subscriber_point1    ${pse_max_power}