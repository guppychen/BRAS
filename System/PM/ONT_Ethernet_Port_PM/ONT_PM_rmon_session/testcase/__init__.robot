*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       ONT_PM_rmon_session_suite_provision
Suite Teardown    ONT_PM_rmon_session_suite_deprovision
Force Tags        @feature=ONT_Ethernet_Port_PM    @subfeature=ONT_PM_rmon_session    @author=Meiqin_Wang
Resource          ./base.robot

*** Variables ***


*** Keywords ***
ONT_PM_rmon_session_suite_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    log    enable uplink-port
    service_point_prov     service_point_list1
    subscriber_point_prov    subscriber_point1
    Wait Until Keyword Succeeds    1 min    5 sec    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present


ONT_PM_rmon_session_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    log    service_point deprovision
    service_point_dprov    service_point_list1