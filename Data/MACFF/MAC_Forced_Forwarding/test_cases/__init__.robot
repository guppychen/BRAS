*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       mac_forced_forwarding_suite_provision
Suite Teardown    mac_forced_forwarding_suite_deprovision
Force Tags        @feature=MACFF    @subfeature=MAC_Forced_Forwarding    @author=wchen
Resource          ./base.robot

*** Variables ***


*** Keywords ***
mac_forced_forwarding_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=wchen
    log    enable uplink-port
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    subscriber_point_check_status_up	subscriber_point1
    subscriber_point_check_status_up      subscriber_point2

mac_forced_forwarding_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=wchen
    log    subscriber_point_deprovision

    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    log    disable uplink port
    service_point_dprov    service_point_list1
    Application Restart Check   eutA