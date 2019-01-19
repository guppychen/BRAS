*** Settings ***
Documentation      LLDP-Config Nearest non-TPMR bridge MAC Destination Address for INNI ports
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Config_Nearest_non_TPMR_bridge_MAC_Destination_Address_for_INNI_ports  
    [Documentation]    LLDP-Config Nearest non-TPMR bridge MAC Destination Address for INNI ports      
    [Tags]       @author=Luna Zhang      @tcid=AXOS_E72_PARENT-TC-4963      @globalid=2534966      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Enable LLDP on an ethernet port to use Nearest Customer bridge
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    lldp destination-agent=${dst_agent_3} 
  
    log    Verify LLDP is enabled by default with destn-agent Nearest Customer bridge on INNI ports
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    dest-agent    ${dst_agent_3}
    
    log    Verify LLDP TLV has the NNearest Customer bridge MAC as its destination address from the CLI command "show lldp agent ethernet "
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    dest-mac      ${dst_mac_3}
    log    start capture
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}    
    
    log    Verify the changed LLDP TLV has the Nearest Bridge MAC as its destination address from wireshark capture
    analyze_packet_count_greater_than    ${save_file_lldp}    eth.dst == ${dst_mac_3}
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4963 teardown
    log    subscriber_point remove_svc and deprovision
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    lldp destination-agent=${dst_agent_1}