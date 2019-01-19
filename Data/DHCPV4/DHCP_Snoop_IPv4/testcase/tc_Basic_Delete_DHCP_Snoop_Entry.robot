*** Settings ***
Documentation     Basic Delete DHCP Snoop Entry
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Basic_Delete_DHCP_Snoop_Entry
    [Documentation]    1	Basic Delete DHCP Snoop Entry: Enable DHCP Snooping on a VLAN. Force subscriber to obtain an IP address via DHCP with a fairly low DHCP lease (60 seconds). Perform the following delete operations: by ip and VLAN(delete). or by vlan only(clear) . Display the DHCP lease table after each delete. -> All delete operations correctly delete the lease is no longer displayed in the lease table.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-667    @feature=DHCPV4    @globalid=2307007    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-667 setup
    [Teardown]   AXOS_E72_PARENT-TC-667 teardown
    log    STEP:1 Basic Delete DHCP Snoop Entry: Enable DHCP Snooping on a VLAN. Force subscriber to obtain an IP address via DHCP with a fairly low DHCP lease (60 seconds). Perform the following delete operations: by ip and VLAN(delete). or by vlan only(clear) . Display the DHCP lease table after each delete. -> All delete operations correctly delete the lease is no longer displayed in the lease table. All Step action expected Results must be correct
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=${lease_time_2}
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
    log    delete dhcp lease and check no lease
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${stag_vlan} ip ${lease_start}
    check_l3_hosts    eutA    0


*** Keywords ***
AXOS_E72_PARENT-TC-667 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-667 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

AXOS_E72_PARENT-TC-667 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-667 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    run keyword and ignore error    Enable Pon Interface    eutA    @{service_model.subscriber_point1.attribute.pon_port}[0]
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}