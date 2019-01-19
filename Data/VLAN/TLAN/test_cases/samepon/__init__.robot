*** Settings ***
Suite Setup       TLAN_suite_provision
Suite Teardown    TLAN_suite_deprovision
Force Tags        @feature=VLAN    @author=Molly Yang    @sub_feature=TLAN
Resource          ../base.robot

*** Keywords ***
TLAN_suite_provision
    log    suite provision for sub_device
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    log   check sub_device status up
    subscriber_point_check_status_up    subscriber_point1
    subscriber_point_check_status_up    subscriber_point2

TLAN_suite_deprovision
    log    suite deprovision for sub_device
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
