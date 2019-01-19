*** Settings ***
Documentation      LLDP-Multiple profiles 
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
LLDP_Multiple_profiles 
    [Documentation]    LLDP-Multiple profiles    
    [Tags]       @author=Luna Zhang     @tcid=AXOS_E72_PARENT-TC-4976      @globalid=2534979      @priority=P2      @eut=NGPON2-4      @eut=10GE-12          @user_interface=CLI
    [Teardown]   case teardown
    log    Configure 6 LLDP profiles 
    prov_lldp_profile    eutA    ${lldp_prf_1}
    prov_lldp_profile    eutA    ${lldp_prf_2}
    prov_lldp_profile    eutA    ${lldp_prf_3}
    prov_lldp_profile    eutA    ${lldp_prf_4}
    prov_lldp_profile    eutA    ${lldp_prf_5}
    prov_lldp_profile    eutA    ${lldp_prf_6}
    prov_lldp_profile    eutA    ${lldp_prf_7}
    prov_lldp_profile    eutA    ${lldp_prf_8}
    
    log    Verify using the show command that 8 LLDP profiles are configured ( 2 default profiles and 6 configured profiles)
    check_running_configure    eutA    lldp-profile    ${lldp_prf_1}  
    check_running_configure    eutA    lldp-profile    ${lldp_prf_2}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_3}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_4}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_5}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_6}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_7}
    check_running_configure    eutA    lldp-profile    ${lldp_prf_8}
          
    log    Configure 7th LLDP profile    
    Run Keyword And Expect Error    *    prov_lldp_profile    eutA    ${lldp_prf_9}
    
    log    delete 7 LLDP profile   
    dprov_lldp_profile    eutA    ${lldp_prf_1}
    dprov_lldp_profile    eutA    ${lldp_prf_2}
    dprov_lldp_profile    eutA    ${lldp_prf_3}
    dprov_lldp_profile    eutA    ${lldp_prf_4}
    dprov_lldp_profile    eutA    ${lldp_prf_5}
    dprov_lldp_profile    eutA    ${lldp_prf_6}
    dprov_lldp_profile    eutA    ${lldp_prf_7}
    dprov_lldp_profile    eutA    ${lldp_prf_8}
*** Keywords ***
case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-4976 teardown
    log    subscriber_point remove_svc and deprovision
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_1}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_2}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_3}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_4}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_5}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_6}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_7}
    Run Keyword And Ignore Error    dprov_lldp_profile    eutA    ${lldp_prf_8}