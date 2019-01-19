*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Layer-2_Service_Classifiers_suite_provision
Suite Teardown    Layer-2_Service_Classifiers_suite_deprovision
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Layer-2_Service_Classifiers_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    log    check ont-profile
#    ${result}    check_ont_profile    eutA    ${service_model.subscriber_point1.attribute.ont_profile_id}    ont-profile=${service_model.subscriber_point1.attribute.ont_profile_id}    ont-ethernet=x1
#    log    ${result}
#    Wait Until Keyword Succeeds    2 min    5 sec    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    wait until keyword succeeds     2 min    5 sec    subscriber_point_check_status_up        subscriber_point1



Layer-2_Service_Classifiers_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    log    service_point deprovision
    service_point_dprov    service_point_list1
    log    delete ont and disable pon port
    Application Restart Check   eutA