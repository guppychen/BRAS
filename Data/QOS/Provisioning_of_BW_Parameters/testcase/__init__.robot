*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Provisioning_of_BW_Parameters_suite_provision
Suite Teardown    Provisioning_of_BW_Parameters_suite_deprovision
Force Tags        @feature=QOS    @subfeature=Provisioning_of_BW_Parameters      @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Provisioning_of_BW_Parameters_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1




Provisioning_of_BW_Parameters_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    log    service_point deprovision
    service_point_dprov    service_point_list1
    log    delete ont and disable pon port
    Application Restart Check   eutA