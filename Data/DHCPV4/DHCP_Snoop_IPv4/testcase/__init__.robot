*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       DHCP_Snoop_IPv4_suite_provision
Suite Teardown    DHCP_Snoop_IPv4_suite_deprovision
Force Tags        @feature=DHCPV4    @subfeature=DHCP_Snoop_IPv4    @author=Ronnie_Yi    @require=2stc1eut1ont   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***


*** Keywords ***
DHCP_Snoop_IPv4_suite_provision
    [Documentation]    suite provision for sub_feature
    [Tags]    @author=Ronnie_yi
    log    suite provision for sub_feature
    log    service_point_provision for uplink side
    set_eut_version
    service_point_prov    service_point_list1
    log    service_point_add_vlan for uplink service
    prov_dhcp_profile    eutA    ${l2_profile_name} 
    prov_vlan    eutA    ${stag_vlan}    l2-dhcp-profile=${l2_profile_name}    
    prov_vlan_egress    eutA    ${stag_vlan}    broadcast-flooding    ENABLED
    service_point_add_vlan    service_point_list1    ${stag_vlan}
    log    subscriber_point_operation for subscriber side
    subscriber_point_prov    subscriber_point1
    subscriber_point_check_status_up	    subscriber_point1

DHCP_Snoop_IPv4_suite_deprovision
    [Documentation]    suite deprovision for sub_feature
    [Tags]    @author=Ronnie_yi
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    run keyword and ignore error    subscriber_point_dprov    subscriber_point1
    log    service_point remove_svc
    run keyword and ignore error    service_point_remove_vlan    service_point_list1    ${stag_vlan}
    log    delete vlan
    run keyword and ignore error    delete_config_object    eutA    vlan    ${stag_vlan}
    run keyword and ignore error    delete_config_object    eutA    l2-dhcp-profile    ${l2_profile_name}
    log    service_point deprovision
    run keyword and ignore error    service_point_dprov    service_point_list1


