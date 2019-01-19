*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_When_ONT_is_off_line_show_default_ont_port_gig_eth_detail
    [Documentation]
      
    ...    1	Show ont-port gig-eth detail	sucessfully		
    ...    2	Show ont-port * detail(only for gig-eth)	sucessfully		
    ...    3	Check PoE Admin Status	The default is disabled		
    ...    4	Check PoE Priority	The default is 2:medium		
    ...    5	Check PoE High Power Mode	display as 0: disabled		
    ...    6	Check Voice Policy Profile	display as none（not defined）		
    ...    7	Check Voice Policy Ownership	No shows		
    ...    8	Check PoE Oper Status	No shows		
    ...    9	Check Voice Policy Status	No shows		
    ...    10	Check PoE Short Detected & PoE Overload Detected	No shows		
    ...    11	Check PoE Detected Mode	No shows		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4686      @globalid=2533416      @priority=P1      @eut=GPON-8r2          @user_interface=CLI 
    [Template]    template_when_ONT_is_off_line_show_default_ont_port_gig_eth_detail
    eutA    subscriber_point1