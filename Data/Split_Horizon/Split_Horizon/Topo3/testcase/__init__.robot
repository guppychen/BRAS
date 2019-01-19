*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       split_horizon_suite_provision
Suite Teardown    split_horizon_suite_deprovision
Force Tags        @feature=split_horizon    @subfeature=split_horizon    @author=joli
Resource          ./base.robot

*** Variables ***


*** Keywords ***
split_horizon_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=joli
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    wait until keyword succeeds    10min    30    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    wait until keyword succeeds    10min    30    check_ont_status    eutA    ${service_model.subscriber_point2.attribute.ont_id}    oper-state=present

split_horizon_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=joli
    log    subscriber_point_deprovision

    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    Application Restart Check   eutA