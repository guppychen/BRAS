*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       igmpv2_suite_provision
Suite Teardown    igmpv2_suite_deprovision
Force Tags        @feature=IGMP    @subfeature=IGMPv2 support    @author=Ansonzhang
Resource          ./base.robot

*** Variables ***

*** Keywords ***
igmpv2_suite_provision
    [Documentation]    suite provision for igmpv2 support
    set_eut_version
    log    suite provision service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    subscriber_point_prov    subscriber_point3
    log    create vlan
    prov_vlan    eutA    ${p_data_vlan}
    prov_vlan    eutA    ${p_data_vlan1}
    log    uplink side provision
    service_point_add_vlan    service_point_list1    ${p_data_vlan},${p_data_vlan1},${p_mvr_vlan}
    log    create multicast profile


igmpv2_suite_deprovision
    [Documentation]    suite deprovision for igmpv2 support
    log    remove the vlan
    service_point_remove_vlan    service_point_list1    ${p_data_vlan},${p_data_vlan1},${p_mvr_vlan}
    log    suite deprovision subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    subscriber_point_dprov    subscriber_point3
    log    service_point remove_svc deprovision
    service_point_dprov    service_point_list1
    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    
    
    