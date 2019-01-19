*** Settings ***
Documentation      LLDP-INNI Port Remove an interface from LLDP profile
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Port_Remove_an_interface_from_LLDP_profile
    [Documentation]    LLDP-INNI Port Remove an interface from LLDP profile    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4978      @globalid=2534981      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
       
    log    Verify LLDP is enabled by default and the interface is assigned to default.inni profile by default 
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    add lldp profile to interface 1
    prov_lldp_profile    eutA    ${lldp_prf_1}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
 
    log    Configure more than one interface with service-role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface2}    interface_role=${interface_role}
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
  
    log    Verify LLDP is enabled by default and the interface is assigned to default.inni profile by default
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface2}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface2}    lldp agent    admin-state    enabled
    
    log    add lldp profile to interface 2
    prov_lldp_profile    eutA    ${lldp_prf_2}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface2}    ${lldp_prf_2}
    
    
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4978 teardown
    log    Remove profiles from the interfaces
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    dprov_lldp_profile    eutA    ${lldp_prf_1}
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface2}    
    dprov_lldp_profile    eutA    ${lldp_prf_2} 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    