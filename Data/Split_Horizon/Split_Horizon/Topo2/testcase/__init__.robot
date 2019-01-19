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
   subscriber_point_check_status_up	    subscriber_point1
   subscriber_point_check_status_up  	subscriber_point2

split_horizon_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=joli

    log    subscriber_point_deprovision
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2