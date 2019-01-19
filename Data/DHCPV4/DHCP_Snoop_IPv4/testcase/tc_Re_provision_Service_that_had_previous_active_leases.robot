*** Settings ***
Documentation     Re-provision Service that had previous active leases
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Re_provision_Service_that_had_previous_active_leases
    [Documentation]    1	Re-provision Service that had previous active leases: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP with a lease time longer than the test. Delete the service. Re-add the service. Redisplay the DHCP lease table. -> Lease is displayed before the delete and not displayed after the delete.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-687    @feature=DHCPV4    @globalid=2307027    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-687 setup
    [Teardown]   AXOS_E72_PARENT-TC-687 teardown
    log    STEP:1 Re-provision Service that had previous active leases: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP with a lease time longer than the test. Delete the service. Re-add the service. Redisplay the DHCP lease table. -> Lease is displayed before the delete and not displayed after the delete. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${traffic_run_time}
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    log    delete dhcp service and check no lease
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan=${ctag_vlan}
    check_l3_hosts    eutA    0
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    log    re-add service and get dhcp lease
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}
    check_l3_hosts    eutA    0
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}

*** Keywords ***
AXOS_E72_PARENT-TC-687 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-687 setup
    log    configuration of service
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=translate-cevlan-tag    cevlan=${ctag_vlan}

AXOS_E72_PARENT-TC-687 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-687 teardown
    log    STC related action
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan=${ctag_vlan}