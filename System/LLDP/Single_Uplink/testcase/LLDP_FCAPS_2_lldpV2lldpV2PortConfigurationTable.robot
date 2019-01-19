*** Settings ***
Documentation      LLDP-FCAPS (2.lldpV2PortConfigurationTable)
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_FCAPS_2_lldpV2lldpV2PortConfigurationTable
    [Documentation]    LLDP-FCAPS (2.lldpV2PortConfigurationTable)    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4981      @globalid=2534984      @priority=P1      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure LLDP protocol on an ethernet interface of DUT1
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    
    log    Connect an ethernet interface of DUT2 which is LLDP enabled to the ethernet interface of DUT1 
    
    log    Verify lldpV2PortConfigAdminStatus adminStatus Enable LLDP
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled
    
    log    Verify lldpV2PortConfigAdminStatus adminStatus Disable LLDP
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    disabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    disabled
    
    log    Verify lldpV2PortConfigNotificationEnable on the interface for INNI, UNI and ENNI ports
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    notifications    enabled
    
    log    enable the lldp admin-state    
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled
    sleep    ${wait_TX_TTR_to_0}
    
    log    Verify lldpV2PortConfigTLVsTxEnable
    
    log    Verify ldpV2PortConfigTLVsTxEnable calix-something-changed-local-tlv is enabled by default
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    calix-something-changed-local-cntr-tlv    \\d+
    
    log    add lldp-profile to interface 
    prov_lldp_profile    eutA    ${lldp_prf_1}    
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable     
    prov_lldp_profile    eutA    ${lldp_prf_1}    calix-something-changed-local-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    calix-something-changed-local-cntr-tlv*   
    prov_lldp_profile    eutA    ${lldp_prf_1}    calix-something-changed-local-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    calix-something-changed-local-cntr-tlv\\s+\\d+
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable ieee8021-management-vid-tlv
    log    not support management yet
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable ieee8021-protocol-identify-tlv
    
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable ieee8023-maximum-frame-size-tlv
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    ieee8023-mtu-tlv*        
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-maximum-frame-size-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    ieee8023-mtu-tlv\\s+\\d+
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable ieee8023-power-mdi-tlv
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-power-mdi-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    ieee8023-power-mdi-tlv*       
    prov_lldp_profile    eutA    ${lldp_prf_1}    ieee8023-power-mdi-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    ieee8023-power-mdi-tlv\\s+"${mdi}"
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable management-address-tlv
    log    no support management yet
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable port-description-tlv
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    description=${des_1}
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    description=${des_1}
    prov_lldp_profile    eutA    ${lldp_prf_1}    port-description-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    port-description-tlv*       
    prov_lldp_profile    eutA    ${lldp_prf_1}    port-description-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    port-description-tlv\\s+${des_1}
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable system-capabilities-tlv
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-capabilities-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    system-capabilities-tlv*       
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-capabilities-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    system-capabilities-tlv\\s+"${sys_cap}"
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable system-description-tlv
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-description-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    system-description-tlv*       
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-description-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    system-description-tlv\\s+"${sys_des}"
    
    log    Verify lldpV2PortConfigTLVsTxEnable enable system-name-tlv
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-name-tlv    suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    system-name-tlv*       
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-name-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    system-name-tlv\\s+${sys_name}
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4981 teardown
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    dprov_lldp_profile    eutA    ${lldp_prf_1}  