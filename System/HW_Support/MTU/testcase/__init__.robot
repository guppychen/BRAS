*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       test_setup
Suite Teardown    test_teardown
Force Tags        @feature=HW_Support     @subfeature=MTU_size_of_9k     @author=pzhang      @user_interface=CLI
Resource          ./base.robot


*** Keywords ***
test_setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1

    log    service_point add vlan
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}



test_teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}

    log    delete vlan
    dprov_vlan    eutA    ${service_vlan}

    log    service_point deprovision
    service_point_dprov    service_point_list1