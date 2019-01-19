*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       vca_suite_provision
Suite Teardown    vca_suite_deprovision
Force Tags        @feature=Video     @subfeature=Video_Channel_Analyzer(VCA)    @author=YUE SUN
Resource          ./base.robot

*** Variables ***


*** Keywords ***
vca_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version        
     
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    
vca_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    service_point deprovision
    service_point_dprov    service_point_list1
    