*** Settings ***
Documentation      LLDP-INNI-Transmit Port Description TLV  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Transmit_Port_Description_TLV 
    [Documentation]    LLDP-INNI-Transmit Port Description TLV    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4952      @globalid=2534955      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    log    STEP1 : Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    STEP2 : Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    STEP3 : Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled 
    
    log    STEP4 : Set the interface description and display the right description configured
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    description=${des_1}
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    description=${des_1} 
    
    
    log    STEP5 : Check the LLDPDU's exchanged between the eth-ports using wireshark  
    log    start capture LLDPDU       
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}

    log    STEP6 : From the wireshark captureVerify the LLDPDU contains exactly one Port Description TLV 
    log    STEP7 : From the wireshark capture verify the TLV type is 4 and type length is 7 bits
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.tlv.type==4 
    
    log    STEP8 : Verify the port description
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    description=${des_1}
    
    log    STEP9 : Change the interface description to a different value
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    description=${des_2}
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    description=${des_2}
    
    log    STEP10 : From the wireshark capture Verify the LLDPDU contains exactly one port-description-tlv TLV
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    port-description-tlv    ${des_2}    
