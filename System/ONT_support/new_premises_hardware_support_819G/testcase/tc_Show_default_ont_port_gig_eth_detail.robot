*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_Show_default_ont_port_gig_eth_detail
    [Documentation]
      
    ...    1	Show ont-port gig-eth detail	sucessfully		
    ...    2	Show ont-port * gig-eth detail	sucessfully		
    ...    3	Show ont-port * detail(only for gig-eth)	sucessfully		
    ...    4	Check PoE Admin Status	The default is disabled		
    ...    5	Check PoE Priority	The default is 2:medium		
    ...    6	Check PoE High Power Mode	display as 0: disabled		
    ...    7	Check Voice Policy Profile	display as none（not defined）		
    ...    8	Check Voice Policy Ownership	The default is 0:omci only		
    ...    9	Check PoE Oper Status	display one kind of status		
    ...    10	Check Voice Policy Status	display as 0：disabled		
    ...    11	Check PoE Short Detected & PoE Overload Detected	display as 0		
    ...    12	Check PoE Detected Mode	display one kind of mode		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4639      @globalid=2533365      @priority=P1      @eut=GPON-8r2          @user_interface=CLI
    [Template]    template_show_default_ont_port_gig_eth_detail
    eutA    subscriber_point1

