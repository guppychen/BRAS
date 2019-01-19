*** Settings ***
Documentation     Subscriber Side Add-Tag Match All with Untagged Subscriber Traffic
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_Add_Tag_Match_All_with_Untagged_Subscriber_Traffic
    [Documentation]    1	Subscriber Side Add-Tag Match-All with Untagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry. Note: When testing ENET the traffic match criteria is the "match-all" by not inserting a VLAN or p-bit as a matching criteria.  When testing GPON/DSL the matching criteria includes an untagged-rule to match all untagged traffic and a tagged rule to match all tagged traffic. 	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-728    @feature=DHCPV4    @globalid=2307072    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-728 setup
    [Teardown]   AXOS_E72_PARENT-TC-728 teardown
    log    STEP:1 Subscriber Side Add-Tag Match-All with Untagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry. Note: When testing ENET the traffic match criteria is the "match-all" by not inserting a VLAN or p-bit as a matching criteria. When testing GPON/DSL the matching criteria includes an untagged-rule to match all untagged traffic and a tagged rule to match all tagged traffic. All Step action expected Results must be correct
    log    get dhcp lease for ont a success
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=10000
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start Arp Nd On All Devices    tg1
    Tg_start_arp_nd_on_all_stream_blocks    tg1

    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}


*** Keywords ***
AXOS_E72_PARENT-TC-728 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-728 setup
    prov_class_map    eutA    ${class_map_name}    ethernet    flow     1    1    any=
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    flow     1
    subscriber_point_add_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
    sleep    ${wait_ont_come_back_in_reality}
    
    
AXOS_E72_PARENT-TC-728 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-728 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name}