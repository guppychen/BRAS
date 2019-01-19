*** Settings ***
Documentation     Enable DHCP Snooping w/ Entry Display
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Enable_DHCP_Snooping_w_Entry_Display
    [Documentation]    Enable DHCP Snooping w/ Entry Display: Enable DHCP Snooping on a VLAN. Force subscriber to obtain an IP address via DHCP. Perform the following displays:show l3-host -> All summary displays display the lease including the following information: Ports, VLAN, IP and mask, MAC addr, host-type.up-down-state.lease-renew-time. dhcp server and Expires Time. All detailed displays include the summary lease information plus: summary displays Ports. DHCP Server	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-665    @feature=DHCPV4    @globalid=2307005    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-665 setup
    [Teardown]   AXOS_E72_PARENT-TC-665 teardown
    log    STEP:Enable DHCP Snooping w/ Entry Display: Enable DHCP Snooping on a VLAN. Force subscriber to obtain an IP address via DHCP. Perform the following displays:show l3-host -> All summary displays display the lease including the following information: Ports, VLAN, IP and mask, MAC addr, host-type.up-down-state.lease-renew-time. dhcp server and Expires Time. All detailed displays include the summary lease information plus: summary displays Ports. DHCP Server All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    mac=${client_mac}    dhcp-server=${server_ip}    gateway1=${server_ip}    host-type=dhcp-lease    up-down-state=up
    check_lease_expire_time    eutA    ${stag_vlan}    ${lease_start}    ${lease_time}
    ${tmp1}    Get_dhcp_lease_first_time    eutA    ${stag_vlan}    ${lease_start}
    ${tmp2}    Get_dhcp_lease_renew_time    eutA    ${stag_vlan}    ${lease_start}
    should be equal as strings    ${tmp1}    ${tmp2}
    

*** Keywords ***
AXOS_E72_PARENT-TC-665 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-665 setup
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan


AXOS_E72_PARENT-TC-665 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-665 teardown
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}