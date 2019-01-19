*** Settings ***
Documentation      LLDP-INNI-Transmit System Name TLV  
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_INNI_Transmit_System_Name_TLV 
    [Documentation]    LLDP-INNI-Transmit System Name TLV    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4953      @globalid=2534956      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    STEP1 : Configure an interface with service role inni
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    interface_role=${interface_role} 
       
    log    STEP2 : Verify that the interface is configured with service role inni 
    check_running_config_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    role=inni
    
    log    STEP3 : Check the interface is LLDP enabled by default 
    log    expected result:should display "lldp-agent profile default.inni", lldp-agent admin-state is enabled
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    profile    None
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    admin-state    enabled 
    
    log    Set the system name
    log    Verify the System name
    log    Change the system name
    log    Verify the System name displays the changed value
    config_hostname    eutA    ${sys_name1}
    sleep     ${wait_for_config_hostname}
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    system-name-tlv    ${sys_name1}
    config_hostname    eutA    ${sys_name2} 
    sleep    ${wait_for_config_hostname}
    check_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    lldp agent    system-name-tlv    ${sys_name2}
    
    log    Connect an INNI interface of DUT1 which is LLDP enabled by default to INNI interface of DUT2 
    log    Verify using the following CLI commands "show lldp neighbor summary".
    log    Verify using the following CLI commands "show lldp neighbor entry port a-ref ". "show lldp neighbor entry a-ref 1 port g1" . "show lldp agent ethernet "

    log    Suppress sending the System Name in the default.inni profile
    log    Verify that System Name is not displayed
    prov_lldp_profile    eutA    ${lldp_prf_1}
    config_interface_with_lldp_profile    eutA    ethernet    ${service_model.service_point1.member.interface1}    ${lldp_prf_1}
   
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-name-tlv    suppress
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    system-name-tlv=suppress
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Not Contain Match    ${res}    system-name-tlv*
            
    log    Transmit the System Name in the default.inni profile
    log    Verify the System Name is displayed
    prov_lldp_profile    eutA    ${lldp_prf_1}    system-name-tlv    transmit
    sleep    ${wait_TX_TTR_to_0}    
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}    system-name-tlv=transmit
    ${res}    Axos Cli With Error Check    eutA    show interface ethernet ${service_model.service_point1.member.interface1} lldp agent 
    Should Match Regexp    ${res}    system-name-tlv\\s+${sys_name2} 
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4953 teardown
    log    subscriber_point remove_svc and deprovision
    remove_lldp_profile_from_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    
    dprov_lldp_profile    eutA    ${lldp_prf_1} 
    log    remove hostname
    config_hostname    eutA    ${sys_name2}    remove_opt=no  
    lldp_admin_state    eutA    ${service_model.service_point1.member.interface1}    enabled