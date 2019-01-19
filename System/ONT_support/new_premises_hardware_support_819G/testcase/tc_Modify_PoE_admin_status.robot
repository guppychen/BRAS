*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Modify_PoE_admin_status
    [Documentation]
      
    ...    1	Set ont-port * poe-admin-status enabled	successfully		
    ...    2	Check the PoE admin Status	The status is enabled		
    ...    3	Set ont-port * poe-admin-status disabled	successfully		
    ...    4	Check the PoE admin Status	The status is disabled		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4658      @globalid=2533384      @priority=P1      @eut=GPON-8r2          @user_interface=CLI  
    [Template]    template_modify_PoE_admin_status
    eutA    ontA    subscriber_point1    ${misc_poe_table}    ${ont_uni_port}