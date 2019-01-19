*** Settings ***
Documentation     interface ont-ethernet option82 action pass
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_interface_ont_ethernet_option82_action_pass
    [Documentation]    1	enable option82 unser vlan. and set option82-action pass on interface ont-ethernet 	success
    ...    2	start dhcp process on IXIA throught ont port. and ont doesn't add option82	can get dhcp lease. and packets received doesn't have option82
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2129    @globalid=2343945    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 enable option82 unser vlan. and set option82-action pass on interface ont-ethernet success
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    svc_vlan=${stag_vlan}    option82-action=pass
    log    STEP:2 start dhcp process on IXIA throught ont port. and ont doesn't add option82 can get dhcp lease. and packets received doesn't have option82
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    check_no_dhcp_option82    tg1    service_p1
    check_no_dhcp_option82    tg1    subscriber_p1

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan


case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}