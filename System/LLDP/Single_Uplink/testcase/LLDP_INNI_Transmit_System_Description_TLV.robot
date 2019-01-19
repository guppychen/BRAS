*** Settings ***
Documentation      LLDP-INNI-Transmit System Description TLV  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Transmit_System_Description_TLV 
    [Documentation]    LLDP-INNI-Transmit System Name TLV    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4954      @globalid=2534957      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    STEP1 : Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    STEP2 : Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    STEP3 : Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled 
    
    log    Configure to send out System Description TLV's
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    system-description-tlv    "${sys_des}"
    
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
    
    log    From the wireshark capture Verify the LLDPDU contains exactly one System Description TLV 
    log    From the wireshark capture verify the TLV type is 6 
    log    From the wireshark capture verify the system description
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.tlv.type == 6 and lldp.tlv.system.desc == "${sys_des}"
    log    Suppress sending the System Description in the default.inni profile
    log    Verify that System Description is not displayed from the CLI commands "show lldp agent ethernet g1" 
    log    Verify that System Description is not displayed using "show lldp neighbor entry port g1 a-ref 1"   
    prov_lldp_profile    eutA    ${lldp_prf_1}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
    
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-description-tlv    suppress
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    system-description-tlv=suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    system-description-tlv*
    
    log    Transmit the System Description in the default.inni profile
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-description-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    system-description-tlv=transmit
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp   ${res}    system-description-tlv\\s+"${sys_des}"
    

*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4954 teardown
    log    subscriber_point remove_svc and deprovision
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    dprov_lldp_profile    eutA    ${lldp_prf_1}  