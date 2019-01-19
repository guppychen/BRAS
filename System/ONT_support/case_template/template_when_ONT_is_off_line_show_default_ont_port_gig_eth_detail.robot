*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***


*** Keywords ***
template_when_ONT_is_off_line_show_default_ont_port_gig_eth_detail
    [Arguments]    ${device}    ${subscriber_point}
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

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_off_line_ont_gig_eth    ${device}    ${attribute.ont_id}
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:1 Show ont-port gig-eth detail sucessfully 
    log    STEP:2 Show ont-port * detail(only for gig-eth) sucessfully 
    log    off-line ont ${attribute.ont_id}
    Wait Until Keyword Succeeds    5 min    5 s    Axos Cli With Error Check    ${device}    perform ont reset ont-id ${attribute.ont_id} forced true 
    check_ont_detail    ${device}    ${attribute.ont_id}
    
    
    log    STEP:3 Check PoE Admin Status The default is disabled 
    log    STEP:4 Check PoE Priority The default is 2:medium 
    check_running_configure    ${device}    interface    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    |    details    
    ...    poe-admin-state=DISABLED    poe-priority=medium 
    
    log    STEP:5 Check PoE High Power Mode display as 0: disabled 
    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    poe-power-detection-status    "PSE disabled"
    
    log    STEP:6 Check Voice Policy Profile display as none（not defined） 
    ${res}    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    should contain    ${res}    No entries found
    
    log    STEP:7 Check Voice Policy Ownership No shows 
    log    STEP:9 Check Voice Policy Status No shows
    log    STEP:8 Check PoE Oper Status No shows 
    log    STEP:10 Check PoE Short Detected & PoE Overload Detected No shows 
    log    STEP:11 Check PoE Detected Mode No shows 
    ${res}    cli    ${device}    show interface ${attribute.interface_type} ${service_model.${subscriber_point}.member.interface1} detail
    Should Not Contain    ${res}     voice-policy-ownership    
    Should Not Contain    ${res}     poe-power-classfication-status     
    Should Not Contain    ${res}     voice-policy-status 
    Should Not Contain    ${res}     poe-short-counter
    Should Not Contain    ${res}     poe-overload-counter
    
    
template_teardown_off_line_ont_gig_eth
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    ont off-line to on-line
    Wait Until Keyword Succeeds    5 min    5 s    Axos Cli With Error Check    ${device}    perform ont reset ont-id ${ont_id} forced false    60
    Wait Until Keyword Succeeds    5 min    5 s    check_ont_status    ${device}    ${ont_id}    oper-state=present
    delete_config_object    ${device}    ont    ${ont_id}