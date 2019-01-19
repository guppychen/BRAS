*** Settings ***
Documentation     Basic Invalid Delete DHCP Lease Parms
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Basic_Invalid_Delete_DHCP_Lease_Parms
    [Documentation]    1	Basic Invalid Delete DHCP Lease Parms: Perform the following invalid DHCP lease deletes: ONT Port (ONT not provisioned, ONT blank, port not valid, port blank) or DSL Port (DSL not provisioned, DSL blank, port not valid, port blank), IP (not present, not an address, blank), GPON port (invalid, blank), MAC (not present, not a MAC, blank), VLAN (not present, not valid, blank) 	command can work, but nothing happen
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-670    @globalid=2307010    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Basic Invalid Delete DHCP Lease Parms: Perform the following invalid DHCP lease deletes: ONT Port (ONT not provisioned, ONT blank, port not valid, port blank) or DSL Port (DSL not provisioned, DSL blank, port not valid, port blank), IP (not present, not an address, blank), GPON port (invalid, blank), MAC (not present, not a MAC, blank), VLAN (not present, not valid, blank) command can work, but nothing happen
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time_2}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    delete dhcp lease with invalid command
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${stag_vlan} ip ${lease_start_2}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    Axos Cli With Error Check    eutA    delete dhcp snoop lease vlan ${Qtag_vlan} ip ${lease_start}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    create svc
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    stop STC
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}