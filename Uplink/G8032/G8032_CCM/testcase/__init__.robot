*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       test_setup
Suite Teardown    test_teardown
Force Tags        @feature=G8032    @subfeature=G8032    @author=pzhang
Resource          ./base.robot


*** Keywords ***
test_setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an G8032 ring with Two nodes

    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    log    Configure data service through G8032 ring
    :FOR    ${g8032_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${g8032_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${g8032_node}.device}    ${service_vlan}    ${dhcp_profile_name}

    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}


    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


test_teardown
    [Documentation]
    [Arguments]
    log    Enter teardown

    log    remove service on ont-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_dprov    subscriber_point1

    log    remove all of the g8032 interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}

    log    deprovision g8032 ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2

    :FOR    ${g8032_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${g8032_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${g8032_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
