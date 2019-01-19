*** Settings ***
Documentation      LLDP-INNI-SCL Counter  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_SCL_Counter 
    [Documentation]    LLDP-INNI-SCL Counter    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4979      @globalid=2534982      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    Check the interface is LLDP enabled by default 
    log    Expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
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
    
    log    Verify from the wireshark capture that SCL counter packets are send out    
    analyze_packet_count_greater_than    ${save_file_lldp}    lldp.orgtlv.oui == 0x00025d
    
    log    Verify SCL Counter TLV are sent out by default "show lldp agent ethernet g1"
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    calix-something-changed-local-cntr-tlv    \\d+
    
    log    Verify the SCL counter using the CLI command "show lldp neighbor entry a-ref 1 port g1"
    log    Verify that SCL counter calix-something-changed-local-tlv is not displayed in "show running-config profile lldp-profile default.inni"     
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    calix-something-changed-local-cntr-tlv*
    
    log    Suppress calix-something-changed-local-cntr-tlv in the default.inni profile 
    log    Verify the calix-something-changed-local-cntr-tlv is displayed     
    prov_lldp_profile    eutA    ${lldp_prf}    calix-something-changed-local-tlv    suppress
    check_running_configure    eutA    lldp-profile    ${lldp_prf}    calix-something-changed-local-tlv=suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    calix-something-changed-local-cntr-tlv*
            
    log    Transmit calix-something-changed-local-cntr-tlv in the default.inni profile
    log    Verify the calix-something-changed-local-cntr-tlv is displayed
    prov_lldp_profile    eutA    ${lldp_prf}    calix-something-changed-local-tlv    transmit
    check_running_configure    eutA    lldp-profile    ${lldp_prf}    calix-something-changed-local-tlv=transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    calix-something-changed-local-cntr-tlv.*
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4979 teardown
    log    deprovision lldp-profile
    dprov_lldp_profile    eutA    ${lldp_prf}