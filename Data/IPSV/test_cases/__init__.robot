*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       IPSV_suite_provision
Suite Teardown    IPSV_suite_deprovision
Force Tags        @feature=IPSV    @author=Molly Yang    @subfeature=IPSV   @eut=GPON-8r2
Resource          ../base.robot

*** Variables ***

*** Keywords ***
IPSV_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    enable uplink-port
    set_eut_version
    service_point_prov    service_point_list1
    log    create 
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    subscriber_point_check_status_up	    subscriber_point1
    subscriber_point_check_status_up	    subscriber_point2

IPSV_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    delete ont and disable pon port
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    log    disable uplink port
    service_point_dprov    service_point_list1
    Application Restart Check   eutA