*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       pon_pm_suite_provision
Suite Teardown    pon_pm_suite_deprovision
Force Tags        @feature=pon pm    @subfeature=pon pm    @author=jerryWu  @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***



*** Keywords ***
pon_pm_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    set eut version and release
    set_eut_version
    log    enable uplink-port
    log    ${service_model.subscriber_point1.attribute.ont_profile_id}
    service_point_prov    service_point_list1
    subscriber_point_prov    subscriber_point1
    Wait Until Keyword Succeeds    1 min    5 sec    subscriber_point_check_status_up    subscriber_point1

pon_pm_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    delete ont and disable pon port
    subscriber_point_dprov    subscriber_point1
    log    disable uplink port
    service_point_dprov    service_point_list1
    Application Restart Check   eutA
