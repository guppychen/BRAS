*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       lldp_suite_provision
Suite Teardown    lldp_suite_deprovision
Force Tags        @feature=LLDP     @subfeature=Single_Uplink    @author=Luna Zhang
Resource          ./base.robot

*** Variables ***


*** Keywords ***
lldp_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version        
     
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    change show-defaults enable
    axos_config_keyword_template    eutA    cli    show-defaults enabled
    
lldp_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    service_point deprovision
    service_point_dprov    service_point_list1
    