*** Settings ***
Documentation      LLDP-Interface disable
Resource          ./base.robot


*** Variables *** 



*** Test Cases ***
LLDP_Interface_disable
    [Documentation]    LLDP-Interface disable   
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4977      @globalid=2534980      @priority=P1      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Verify from command , tx-state "TX_IDLE" , tx-tmr-state " TX_TIMER_IDLE" , rx-state "RX_WAIT_FOR_FRAME"
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-state    TX_IDLE
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-tmr-state     TX_TIMER_IDLE
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    rx-state    RX_WAIT_FOR_FRAME
    
    log    Disable the interface using the shutdown command
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    
    log    Verify from command, tx-state "TX_IDLE" , tx-tmr-state " TX_TIMER_IDLE" , rx-state "LLDP_WAIT_PORT_OPERATIONAL"     
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-state    TX_IDLE
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-tmr-state     TX_TIMER_IDLE
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    rx-state    LLDP_WAIT_PORT_OPERATIONAL    
    
    log    start capture
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}
    
    log    Verify from the wireshark capture that LLDP packets are not sent out
    analyze_packet_count_equal    ${save_file_lldp}    lldp    0               
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4977 teardown
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}