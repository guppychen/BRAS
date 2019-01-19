*** Settings ***
Documentation      LLDP-FCAPS (1.lldpV2Configuration group attributes)
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_FCAPS_1_lldpV2Configuration_group_attributes
    [Documentation]    LLDP-FCAPS (1. lldpV2Configuration group attributes)    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4980      @globalid=2534983      @priority=P1      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    log    Configure LLDP protocol on an ethernet interface of DUT1
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Connect an ethernet interface of DUT2 which is LLDP enabled to the ethernet interface of DUT1 
    
    log    Verify all the lldpV2Configuration group attributes using the CLI commands 
    
    log    Verify msgTxInterval using the CLI commands
    log    Verify msgTxHold using the CLI commands    
    log    Verify reinitDelay using the CLI commands
    log    Verify txCreditMax using the CLI commands
    log    Verify msgFastTx using the CLI commands
    log    Verify txFastInit using the CLI commands   
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.service_point1.member.interface1}    ethernet
    ${res}    cli    eutA    show lldp agent summary   
    Should Match Regexp    ${res}    &{dict_intf}[shelf]\\s+&{dict_intf}[slot]\\s+&{dict_intf}[port]\\s+nearest-bridge\\s+-\\s+enabled\\s+enabled\\s+30\\s+1\\s+4\\s+2\\s+5\\s+4
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-interval    30        
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-hold    4
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    reinit-delay    2   
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    credit-max    5
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    fast-tx    1   
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-fast-init    4          
