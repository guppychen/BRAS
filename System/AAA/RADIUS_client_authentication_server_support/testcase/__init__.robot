*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       radius_suite_provision
Suite Teardown    radius_suite_deprovision
Force Tags        @feature=AAA     @subfeature=RADIUS_client_authentication_server_support    @author=YUE SUN
Resource          ./base.robot

*** Variables ***


*** Keywords ***
radius_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version
     
    log    service_point_provision for uplink side
    prov_radius_server    eutB_root    ${radius_server}    secret=${secret}    retry=${radius_retry}
    prov_aaa_authentication_order    eutB_root    ${authentication}
    
radius_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    service_point deprovision
    dprov_radius_server    eutB_root    ${radius_server} 
    dprov_aaa_authentication_order    eutB_root    ${authentication}