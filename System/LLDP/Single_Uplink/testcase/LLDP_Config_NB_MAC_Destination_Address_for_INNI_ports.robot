*** Settings ***
Documentation      LLDP-Config NB MAC Destination Address for INNI ports
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Config_NB_MAC_Destination_Address_for_INNI_ports  
    [Documentation]    LLDP-Config NB MAC Destination Address for INNI ports      
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4961      @globalid=2534964      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI 
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    
    log    Verify LLDP is enabled by default with destn-agent Nearest-Bridge on INNI ports
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    dest-agent    ${dst_agent_1}
    
    log    Verify LLDP TLV has the Nearest Bridge MAC as its destination address from the CLI command "show lldp agent ethernet "
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    dest-mac      ${dst_mac_1}

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
    analyze_packet_count_greater_than    ${save_file_lldp}    eth.dst == ${dst_mac_1}
