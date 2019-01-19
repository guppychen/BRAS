*** Settings ***
Documentation      LLDP-Reinitalization Delay 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Reinitalization_Delay
    [Documentation]    LLDP-Reinitalization Delay    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4971      @globalid=2534974      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    log    Configure LLDP protocol on an ethernet interface 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    
    log    Verify that the LLDP adminState is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Verify that the default value for lldp reinitDelay is 2
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    reinit-delay    2
    ${res}    cli    eutA    show lldp agent summary    
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.service_point1.member.interface1}    ethernet
    Should Match Regexp    ${res}    &{dict_intf}[shelf]\\s+&{dict_intf}[slot]\\s+&{dict_intf}[port]\\s+nearest-bridge\\s+-\\s+enabled\\s+enabled\\s+30\\s+1\\s+4\\s+2       
