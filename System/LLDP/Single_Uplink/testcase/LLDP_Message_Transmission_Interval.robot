*** Settings ***
Documentation      LLDP-Message Transmission Interval
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Message_Transmission_Interval
    [Documentation]    LLDP-Message Transmission Interval    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4969      @globalid=2534972      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    log    Configure LLDP protocol on an ethernet interface 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    
    log    Verify that the LLDP adminState is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Verify that the default value for lldp msgTxInterval is 30
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    tx-interval    30
    ${res}    cli    eutA    show lldp agent summary    
    &{dict_intf}    get_shelf_slot_interface_info    ${service_model.service_point1.member.interface1}    ethernet
    Should Match Regexp    ${res}    &{dict_intf}[shelf]\\s+&{dict_intf}[slot]\\s+&{dict_intf}[port]\\s+nearest-bridge\\s+-\\s+enabled\\s+enabled\\s+30
    
    log    start capture   
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}
    
    log    Verify that the LLDP frames are sent out every 30 seconds     
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.tlv.type==0 and lldp.tlv.type==1 and lldp.tlv.type==2 and lldp.tlv.type==3    
    
