*** Settings ***
Documentation      LLDP Enable Disable - INNI ports
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Enable_Disable_INNI_ports
    [Documentation]    LLDP-INNI-Default Enabled    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4960      @globalid=2534963      @priority=P1      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Disable LLDP on the inni interface
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled
    
    log    Verify that LLDP is disabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    disabled
    
    log    Enable LLDP again and verify the neighbors
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
