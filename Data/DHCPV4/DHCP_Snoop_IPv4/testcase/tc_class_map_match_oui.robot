*** Settings ***
Documentation     DHCPv4 Snoop Agent must support parsing of the source MAC OUI on DHCP DISCOVER and REQUEST packets, allowing for the provisioning of OUI values of interest to other subsystems, including video.The current video subsystem wants to be notified of DHCP lease entries whose OUI identifies them as STB.
Resource          ./base.robot
Force Tags        @feature=DHCPV4    @subfeature=DHCP_Snoop_IPv4

*** Variables ***


*** Test Cases ***
tc_class_map_match_oui
    [Documentation]    1	configure class-map match oui	success
    ...    2	start dhcp process	only clients with mac which is oui mac can get dhcp lease
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-743    @feature=DHCPV4    @globalid=2307087    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-743 setup
    [Teardown]   AXOS_E72_PARENT-TC-743 teardown
    log    STEP:1 configure class-map match oui success
    prov_class_map    eutA    ${class_map_name}    ethernet    flow     1    1    src-oui=${match_oui}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name}    flow     1
    subscriber_point_add_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    log    STEP:2 start dhcp process only clients with mac which is oui mac can get dhcp lease
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    Tg Save Config Into File    tg1     /tmp/stream.xml
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}


*** Keywords ***
AXOS_E72_PARENT-TC-743 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-743 setup


AXOS_E72_PARENT-TC-743 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-743 teardown
    log    delete stc config
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    delete svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${stag_vlan}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name}
