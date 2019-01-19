*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       pppoe_suite_provision
Suite Teardown    pppoe_suite_deprovision
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli
Resource          ./base.robot

*** Variables ***

*** Keywords ***
pppoe_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=joli
    set_eut_version
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    CLI    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
    subscriber_point_prov    subscriber_point1
    subscriber_point_check_status_up    subscriber_point1
    subscriber_point_prov    subscriber_point2
    subscriber_point_check_status_up    subscriber_point2
pppoe_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=joli
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    log    service_point deprovision
    service_point_dprov    service_point_list1
