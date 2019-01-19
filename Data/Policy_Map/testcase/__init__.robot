*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       eth_policy_map_suite_provision
Suite Teardown    eth_policy_map_suite_deprovision
Force Tags        @feature=Policy Map    @subFeature=10GE-12: Policy Map support    @author=MinGu
Resource          ./base.robot

*** Variables ***


*** Keywords ***
eth_policy_map_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version
    
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    service_point add svc
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1 
    
eth_policy_map_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1    
    
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    
    log    service_point deprovision
    service_point_dprov    service_point_list1