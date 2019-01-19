*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       DHCP_Lease_Persistence_suite_provision
Suite Teardown    DHCP_Lease_Persistence_suite_deprovision
Force Tags        @feature=DHCPV4    @subfeature=DHCP_Lease_Persistence    @author=Ronnie_Yi
Resource          ./base.robot

*** Variables ***


*** Keywords ***
DHCP_Lease_Persistence_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Ronnie_yi
    set eut version
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    service_point_prov    service_point_list1
    log    service_point_add_vlan for uplink service
    prov_dhcp_profile    eutA    ${l2_profile_name}
    prov_vlan    eutA    ${stag_vlan}    l2-dhcp-profile=${l2_profile_name}    mff=enabled    source-verify=enabled
    service_point_add_vlan    service_point_list1    ${stag_vlan}
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    wait until keyword succeeds    10min    30    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present


DHCP_Lease_Persistence_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Ronnie_yi
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_dprov    subscriber_point1
    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${stag_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${stag_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ${l2_profile_name}
    log    service_point deprovision
    service_point_dprov    service_point_list1
    cli    eutA    copy running-config startup-config
    Application Restart Check   eutA