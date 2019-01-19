*** Settings ***
Documentation      LLDP-INNI-Transmit Organizationally Specific Maximum Frame Size TLV  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Transmit_Organizationally_Specific_Maximum_Frame_Size_TLV  
    [Documentation]    LLDP-INNI-Transmit Organizationally Specific Maximum Frame Size TLV  
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4959      @globalid=2534962      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled 
    
    log    add lldp profile to interface
    prov_lldp_profile    eutA    ${lldp_prf_1}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
    
    log    Configure or enable an interface to send out Maximum frame size TLV
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    mtu=${mtu_1}
    
    
    log    Check the LLDPDU's exchanged between the eth-ports using wireshark    
    log    start capture
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}
    analyze_packet_count_equal    ${save_file_lldp}    lldp.tlv.type==127 and lldp.orgtlv.oui==0x00120f and lldp.ieee.802_3.max_frame_size==${mtu_1}     
    
    log    From the wireshark capture verify the TLV type is 127 
    log    From the wireshark noapture Verify that the Organization unique code is IEEE 802.3 (0x00120f)
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv    transmit
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv=transmit
    
    log    Verify from the wireshark capture the maximum frame size value is to the configured value
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.tlv.type==127 and lldp.orgtlv.oui==0x00120f and lldp.ieee.802_3.max_frame_size==${mtu_1}   
    
    log    Verify from the CLI command,"ieee8023-maximum-frame-size-tlv transmit" is displayed
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv=transmit
    
    log    Verify the configured MTU value is displayed against "ieee8023-mtu-tlv " field from the CLI commands    
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    ieee8023-mtu-tlv    ${mtu_1} 
    
    log    Change the MTU value on an interface
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    mtu=${mtu_2}
    
    log    start capture
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled        
    start_capture    tg1    service_p1 
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_for_report_send}
    stop_capture    tg1    service_p1
    Tg Save Config Into File    tg1     /tmp/lldp_report.xml
    ${save_file_lldp}    set variable    /tmp/${TEST NAME}_lldp.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_lldp}    
    
    log    Verify the changed MTU value is displayed in the wireshark capture
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.ieee.802_3.max_frame_size==${mtu_2}             
    
    log    Verify the configured MTU value is displayed against "ieee8023-mtu-tlv " field from the CLI commands 
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    ieee8023-mtu-tlv    ${mtu_2}
    
    log    Verify the configured MTU value is displayed against "ieee8023-mtu-tlv " using "show lldp neighbor entry port g1 a-ref 1"
    
    log    Suppress sending the ieee8023-maximum-frame-size-tlv in the default.inni profile
    log    Verify that ieee8023-maximum-frame-size-tlv is not displayed from the CLI commands
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv    suppress
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv=suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    ieee8023-mtu-tlv*
    
    log    Verify that ieee8023-maximum-frame-size-tlv is not displayed using "show lldp neighbor entry port g1 a-ref 1"
    
    log    Transmit the ieee8023-maximum-frame-size-tlv in the default.inni profile
    log    Verify the configured MTU value is displayed against "ieee8023-mtu-tlv " field from the CLI commands
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv=transmit
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    ieee8023-mtu-tlv\\s+${mtu_2}
    
    log    Verify the configured MTU value is displayed against "ieee8023-mtu-tlv " using "show lldp neighbor entry port g1 a-ref 1"
    
    
    
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4959 teardown
    log    subscriber_point remove_svc and deprovision
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    dprov_lldp_profile    eutA    ${lldp_prf_1} 