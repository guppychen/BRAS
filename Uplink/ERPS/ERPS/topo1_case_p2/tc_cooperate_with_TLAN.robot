*** Settings ***
Documentation     1.Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_cooperate_with_TLAN
    [Documentation]    1	Configure TLAN, check protocol packets	protocol packets can pass
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1285    @globalid=2319035    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure TLAN, check protocol packets protocol packets can pass
    prov_vlan    eutA    ${service_vlan}    mode=ELAN
    create_dhcp_server    tg1    dhcps_stag    service_p1    ${server_mac}    ${server_ip}    ${pool_ip_start}    ${service_vlan}    lease_time=100
    create_dhcp_client    tg1    dhcpc_stag    subscriber_p1    grp_stag     ${client_mac}    ${subscriber_vlan}    session=1
    Tg Control Dhcp Server    tg1    dhcps_stag    start
    Tg Control Dhcp Client    tg1    grp_stag    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}  


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes
    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    
    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}    mode=ELAN
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}

     log    subscriber_point_l2_basic_svc_provision
     subscriber_point_prov    subscriber_point1
     subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


case teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    remove service on ont-port

    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_dprov    subscriber_point1
    
    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}
    
    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
