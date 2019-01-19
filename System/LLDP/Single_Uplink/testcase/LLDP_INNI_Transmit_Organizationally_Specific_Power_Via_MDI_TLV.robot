*** Settings ***
Documentation      LLDP-INNI-Transmit Organizationally Specific Power Via MDI TLV  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Transmit_Organizationally_Specific_Power_Via_MDI_TLV 
    [Documentation]    LLDP-INNI-Transmit Specific Power Via MDI TLV     
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4958      @globalid=2534961      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
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
    log    Enable the TLV in the profile to transmit the Power Via MDI TLV
    prov_lldp_profile    eutA    ${lldp_prf_1}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-power-mdi-tlv    transmit
    
    log    Verify that in E5-520 against ieee8023-power-mdi-tlv "Not Supported is displayed" and for E5-308 for PPOE ports u get the required output
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    ieee8023-power-mdi-tlv\\s+"${mdi}"
    
    log    Suppress sending the System Description in the default.inni profile
    log    Verify that Power Via MDI TLV is not displayed from the CLI commands"show lldp agent ethernet g11"
    log    Verify that Power Via MDI TLV is not displayed using "show lldp neighbor entry port g11 a-ref 1"    
    
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-power-mdi-tlv    suppress
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-power-mdi-tlv=suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    ieee8023-power-mdi-tlv*
    
    log    Transmit the System Description in the default.inni profile
    log    Verify that in E5-520 it is displayed as Not Supported and E5-308 the required output for PPOE ports
    log    Verify the Power Via MDI TLV in E5-520 it is displayed as Not Supported and E5-308 the required output for PPOE ports from the CLI commands "show lldp agent ethernet g11"
    log    Verify the Power Via MDI TLV in E5-520 it is displayed as Not Supported and E5-308 the required output for PPOE ports using the CLI command "show lldp neighbor entry port g11 a-ref 1" 
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-power-mdi-tlv    transmit
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    ieee8023-power-mdi-tlv=transmit
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    ieee8023-power-mdi-tlv\\s+"${mdi}"

*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4958 teardown
    log    subscriber_point remove_svc and deprovision
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    dprov_lldp_profile    eutA    ${lldp_prf_1}  