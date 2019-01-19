*** Settings ***
Documentation      LLDP-INNI-Default Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Default_Enabled
    [Documentation]    LLDP-INNI-Default Enabled    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4945      @globalid=2534948      @priority=P1      @eut=NGPON2-4      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    start capture
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}
    
    log    Verify that the Mandatory TLVs are sent out in the Wireshark Captures every 30 secs
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.tlv.type==0 and lldp.tlv.type==1 and lldp.tlv.type==2 and lldp.tlv.type==3          
*** Keywords ***    
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4945 teardown
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled