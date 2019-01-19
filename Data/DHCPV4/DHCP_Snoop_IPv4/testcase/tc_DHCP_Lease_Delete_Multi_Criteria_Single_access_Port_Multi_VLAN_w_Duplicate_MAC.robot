*** Settings ***
Documentation     DHCP Lease Delete Multi Criteria (Single access Port Multi VLAN w/ Duplicate MAC)
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Lease_Delete_Multi_Criteria_Single_access_Port_Multi_VLAN_w_Duplicate_MAC
    [Documentation]    1	DHCP Lease Delete Multi Criteria (Single subcriber Port Multi VLAN w/ Duplicate MAC): Enable DHCP Snooping on an access port with two services. Force a client on each service to obtain an IP address. Both clients use the same MAC address. Display lease table. Attempt the following DHCP lease deletes that should fail: by MAC only, Ports, ONT-port/Client MAC, Attempt the following DHCP lease deletes that should succeed: VLAN only, by VLAN/ip. Display the lease table after each delete. -> All deletes indicated as failed should fail without removing any leases. All deletes indicated as succeed should be successful removing only the lease deleted from the display.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-668    @globalid=2307008    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 DHCP Lease Delete Multi Criteria (Single subcriber Port Multi VLAN w/ Duplicate MAC): Enable DHCP Snooping on an access port with two services. Force a client on each service to obtain an IP address. Both clients use the same MAC address. Display lease table. Attempt the following DHCP lease deletes that should fail: by MAC only, Ports, ONT-port/Client MAC, Attempt the following DHCP lease deletes that should succeed: VLAN only, by VLAN/ip. Display the lease table after each delete. -> All deletes indicated as failed should fail without removing any leases. All deletes indicated as succeed should be successful removing only the lease deleted from the display. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    create_dhcp_server    tg1    ${server_name_2}    service_p1    ${server_mac_2}     ${server_ip_2}     ${lease_start_2}    ${Qtag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name_2}    subscriber_p1    ${group_name_2}    ${client_mac_2}    ${Qtag_vlan_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Control Dhcp Server    tg1    ${server_name_2}    start
    Tg Control Dhcp Client    tg1    ${group_name_2}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    wait until keyword succeeds    10    1    check_l3_hosts    eutA    2
    log    delete dhcp lease with wrong ip or vlan
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${stag_vlan} ip ${lease_start_2}
    check_l3_hosts    eutA    2
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${Qtag_vlan} ip ${lease_start}
    check_l3_hosts    eutA    2
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${stag_vlan} ip ${lease_start}
    check_l3_hosts    eutA    1    ${Qtag_vlan}    ${service_model.subscriber_point1.name}    ip=${lease_start_2}
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${Qtag_vlan} ip ${lease_start_2}
    check_l3_hosts    eutA    0    



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}
    prov_vlan    eutA    ${Qtag_vlan}    l2-dhcp-profile=${l2_profile_name}
    service_point_add_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cevlan_action=remove-cevlan    cfg_prefix=2

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name_2}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name_2}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name_2}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name_2}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${Qtag_vlan}    cfg_prefix=2
    service_point_remove_vlan    service_point_list1    ${stag_vlan},${Qtag_vlan}    cfg_prefix=2
    delete_config_object    eutA    vlan    ${Qtag_vlan}
    service_point_add_vlan    service_point_list1    ${stag_vlan}
