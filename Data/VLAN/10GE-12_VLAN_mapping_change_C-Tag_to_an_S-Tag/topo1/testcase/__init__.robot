*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       10GE-12_VLAN_mapping_add_an_S-tag_suite_provision
Suite Teardown    10GE-12_VLAN_mapping_add_an_S-tag_suite_deprovision
Force Tags        @feature=VLAN    @subfeature=VLAN mapping: change C-Tag to an S-Tag    @author=AnsonZhang
Resource          ./base.robot

*** Variables ***


*** Keywords ***
10GE-12_VLAN_mapping_add_an_S-tag_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version        
     
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1

    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1 

10GE-12_VLAN_mapping_add_an_S-tag_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1 

    log    service_point deprovision
    service_point_dprov    service_point_list1
        
    
    
