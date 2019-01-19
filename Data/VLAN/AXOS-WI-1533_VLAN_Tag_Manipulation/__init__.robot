*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       Vlan_Tag_Manipulation_provision
Suite Teardown    Vlan_Tag_Manipulation_deprovision
#Test Setup        Reset_ONT
Force Tags        @require=2stc1eut1ont        @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
Vlan_Tag_Manipulation_provision
    [Documentation]    suite provision for sub_feature
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    # run keyword and ignore error   Reload The Device With Default Startup   eutA
    # sleep  40s
    # wait until keyword succeeds    5 min    1 min    check version   eutA
    # sleep   10s
    service_point_prov    service_point_list1
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_check_status_up    subscriber_point1

Vlan_Tag_Manipulation_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    log    service_point deprovision
    service_point_dprov    service_point_list1
    Application Restart Check   eutA

Reset_ONT
    [Documentation]    suite deprovision for sub_feature
    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
    wait until keyword succeeds    10min    5s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present