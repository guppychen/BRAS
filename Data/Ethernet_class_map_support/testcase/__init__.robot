*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       eth_class_map_suite_provision
Suite Teardown    eth_class_map_suite_deprovision
Force Tags        @feature=Ethernet Class Map    @subfeature=10GE-12: Ethernet class map support    @author=MinGu
Resource          ./base.robot

*** Variables ***


*** Keywords ***
eth_class_map_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version

    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    service_point add svc
    prov_vlan    eutA    ${service_vlan_1}
    prov_vlan    eutA    ${service_vlan_2}
    service_point_add_vlan    service_point_list1    ${service_vlan_1},${service_vlan_2}
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1

eth_class_map_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1

    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan_1},${service_vlan_2}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan_1}
    delete_config_object    eutA    vlan    ${service_vlan_2}
    log    service_point deprovision
    service_point_dprov    service_point_list1



