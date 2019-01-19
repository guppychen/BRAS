*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Discovery_and_Inventory_of_XFP_and_PON_OIMs_suite_provision
Suite Teardown    Discovery_and_Inventory_of_XFP_and_PON_OIMs_suite_deprovision
Force Tags        @feature=HW_Support   @subfeature=Discovery_and_Inventory_of_XFP_and_PON_OIMs    @author=PEIJUN_LIU
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Discovery_and_Inventory_of_XFP_and_PON_OIMs_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=PEIJUN_LIU
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    log    enable uplink-port
    service_point_prov     service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    Wait Until Keyword Succeeds    1 min    5 sec    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present


Discovery_and_Inventory_of_XFP_and_PON_OIMs_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=PEIJUN_LIU
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    log    delete ont and disable pon port
    subscriber_point_dprov    subscriber_point1
    log    disable uplink port
    log    service_point deprovision
    service_point_dprov    service_point_list1
