*** Settings ***
Documentation     Lease Timeout
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Lease_Timeout
    [Documentation]    1	Lease Timeout: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP. Shutdown client without sending a DHCP Release or shutting down the physical link. Display DHCP lease table periodically until after DHCP timeout. -> Lease expires time is decremented until the lease time out. When the lease times out it is no longer displayed in the table.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-683    @feature=DHCPV4    @globalid=2307023    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-683 setup
    [Teardown]   AXOS_E72_PARENT-TC-683 teardown
    log    STEP:1 Lease Timeout: Enable DHCP Snooping on service to an access interface. Force at least one client to obtain an IP address via DHCP. Shutdown client without sending a DHCP Release or shutting down the physical link. Display DHCP lease table periodically until after DHCP timeout. -> Lease expires time is decremented until the lease time out. When the lease times out it is no longer displayed in the table. All Step action expected Results must be correct
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=${lease_time}
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
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    log    check dhcp lease can expire when disable pon port
    Disable Pon Interface    eutA    @{service_model.subscriber_point1.attribute.pon_port}[0]
    wait until keyword succeeds    ${lease_time}    5     check_l3_hosts    eutA    0



*** Keywords ***
AXOS_E72_PARENT-TC-683 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-683 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

AXOS_E72_PARENT-TC-683 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-683 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    Enable Pon Interface    eutA    @{service_model.subscriber_point1.attribute.pon_port}[0]
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}
    # modified by llin 2017.9.30 for AT-3093
#    sleep    ${wait_ont_come_back_in_reality}
    wait until keyword succeeds    10min    10s    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    # modified by llin 2017.9.30 for AT-3093
