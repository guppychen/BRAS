*** Settings ***
Documentation     unlink ont with dhcp lease
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_unlink_ont_with_dhcp_lease
    [Documentation]    1	get dhcp lease for ont a	success
    ...    2	perform ont unlink and show l3-host	lease table is no longer exist after ont up after unlink
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-706    @feature=DHCPV4    @globalid=2307047    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-706 setup
    [Teardown]   AXOS_E72_PARENT-TC-706 teardown
    log    STEP:1 get dhcp lease for ont a success
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}   lease_time=10000
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
    log    STEP:2 perform ont unlink and show l3-host lease table is no longer exist after ont up after unlink
    Axos Cli With Error Check    eutA    perform ont unlink ont-id ${service_model.subscriber_point1.attribute.ont_id}
    sleep    ${wait_ont_come_back_in_reality}
    wait until keyword succeeds    ${wait_ont_card_up_time}    20    check_ont_status    eutA    ${service_model.subscriber_point1.attribute.ont_id}    oper-state=present
    check_l3_hosts    eutA    0

*** Keywords ***
AXOS_E72_PARENT-TC-706 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-706 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

AXOS_E72_PARENT-TC-706 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-706 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}