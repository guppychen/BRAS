*** Settings ***
Documentation
Resource     ../base.robot

*** Variables ***

    
*** Keywords ***
template_show_default_ont_port_gig_eth_detail
    [Arguments]    ${device}    ${subscriber_point}    
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

    
    [Tags]     @author=YUE SUN     @user_interface=CLI    
    [Teardown]     template_teardown_show_ont_gig_eth    ${device}    ${attribute.ont_id}
    
    log    set test variable
    ${attribute}    set variable    ${service_model.${subscriber_point}.attribute}
    
    log    provision ont ${attribute.ont_id}
    prov_ont    ${device}    ${attribute.ont_id}    ${attribute.ont_profile_id}    ${attribute.vendor_id}    ${attribute.serial_number}
    Wait Until Keyword Succeeds    2 min    5 s    check_ont_linkage    ${device}    ${attribute.ont_id}    Confirmed    Serial-Number
    log    provision ont-port role uni
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    role    ${attribute.interface_role}
    
    log    STEP:1 Show ont-port gig-eth detail sucessfully 
    log    STEP:2 Show ont-port * gig-eth detail sucessfully 
    log    STEP:3 Show ont-port * detail(only for gig-eth) sucessfully 
    check_ont_detail    ${device}    ${attribute.ont_id}
    Axos Cli With Error Check    ${device}    show interface ${attribute.interface_type} ${service_model.${subscriber_point}.member.interface1} detail
    
    log    STEP:4 Check PoE Admin Status The default is disabled 
    log    STEP:5 Check PoE Priority The default is 2:medium 
    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    | details
    ...    poe-admin-state=DISABLED    poe-priority=medium

    log    STEP:6 Check PoE High Power Mode display as 0: disabled 
    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    poe-power-detection-status    "PSE disabled"
    log    STEP:7 Check Voice Policy Profile display as none（not defined） 
    ${res}    check_running_config_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    voice-policy-profile
    should contain    ${res}    No entries found
    
    log    STEP:8 Check Voice Policy Ownership The default is 0:omci only 
    prov_port_parameter    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    poe-admin-state    ENABLED
    run keyword if    '${attribute.voice}'=='true'    Wait Until Keyword Succeeds    2 min    5 s    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    voice-policy-ownership    OMCI-Only
        
    log    STEP:9 Check PoE Oper Status display one kind of status
    log    STEP:10 Check Voice Policy Status display as 0：disabled 
    run keyword if    '${attribute.voice}'=='true'    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    voice-policy-status    disable
    
    log    STEP:11 Check PoE Short Detected & PoE Overload Detected display as 0 
    run keyword if    '${attribute.poe}'=='true'    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    poe-short-counter    0
    run keyword if    '${attribute.poe}'=='true'    check_interface    ${device}    ${attribute.interface_type}    ${service_model.${subscriber_point}.member.interface1}    detail    poe-overload-counter    0
    
    log    STEP:12 Check PoE Detected Mode display one kind of mode 


template_teardown_show_ont_gig_eth
    [Arguments]    ${device}    ${ont_id}
    [Documentation]
    log    template teardown
    delete_config_object    ${device}    ont    ${ont_id}