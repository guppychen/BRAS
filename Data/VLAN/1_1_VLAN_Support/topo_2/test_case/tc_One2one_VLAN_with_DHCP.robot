*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_One2one_VLAN_with_DHCP
    [Documentation]    1.Verify that DHCP works well under one2one VLAN mode
    [Tags]    @globalid=2318827    @tcid=AXOS_E72_PARENT-TC-1182    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    create_dhcp_server    tg1    ${server_name}    p1    ${server_mac}    ${server_ip}    ${pool_ip_start}
    ...    ${service_vlan}    ${cvlan_one2one_1}    lease_time=10000
    create_dhcp_client    tg1    ${client_name}    p2    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    p2    ${lease_negociate_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${service_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    p2    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic    tg1
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    log    stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${error_rate}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: set vlan ${service_vlan} mode as one2one
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    prov_vlan    eutA    ${service_vlan}    l2-dhcp-profile=${dhcp_profile_name}
    log    step2: add ${service_model.service_point1.member.interface1} and ${service_model.service_point2.member.interface1} to VLAN ${service_vlan} with transport-service-profile
    service_point_add_vlan    service_point_list1    ${service_vlan}
    prov_class_map    eutA    ${class_map_name}    ${class_map_type}    flow    ${flow_index}    ${rule_index}
    ...    untagged=${EMPTY}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    sub_view_type=flow    sub_view_value=${flow_index}
    log    step3: apply VLAN ${service_vlan} to ONT1
    log    step4: set (S;C) tags for ONT1 as (${service_vlan};${cvlan_one2one_1})
    subscriber_point_add_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}

teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc_one2one    subscriber_point1    ${service_vlan}    ${cvlan_one2one_1}    ${policy_map_name}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan policy-map class-map
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ${class_map_type} ${class_map_name}
