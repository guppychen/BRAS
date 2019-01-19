*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_PoE_Priority
    [Documentation]
      
    ...    1	Set ont-port * poe-priority x；The available values are 3: low 2:medium（default） 1: high	successfully		
    ...    2	Check PoE Priority	display correctly		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4640      @globalid=2533366      @priority=P2      @eut=GPON-8r2          @user_interface=CLI  
    [Template]    template_modify_PoE_Priority
    eutA    ontA    subscriber_point1    ${misc_poe_table}    ${ont_uni_port}    ${poe_priority_high}    ${poe_priority_highnum}
   
    