*** Settings ***
Documentation     Opt82 Policy Toggle w/ Opt82
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Opt82_Policy_Toggle_w_Opt82
    [Documentation]    1	Provision a service with user Opt82 insertion enabled and Opt82 policy set to pass	Succeed
    ...    2	DHCP Snooping is enabled on the VLAN	Succeed
    ...    3	Force a client to attempt to obtain DHCP address with Opt82	Succeed
    ...    4	Modify the insertion policy to insert and repeat test. 	All DHCP messages are forwarded toward the server with the client inserted Opt82
    ...    5	Modify the insertion policy to pass and repeat test. 	All DHCP messages are forwarded toward the server with the client inserted Opt82
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2212    @globalid=2344028    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Provision a service with user Opt82 insertion enabled and Opt82 policy set to pass Succeed
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    svc_vlan=${stag_vlan}    option82-action=pass
    log    STEP:2 DHCP Snooping is enabled on the VLAN Succeed
    log    STEP:3 Force a client to attempt to obtain DHCP address with Opt82 Succeed
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:5 Capture entire DHCP transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should default to a format as Hostnameribed in the table above.
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    check_no_dhcp_option82    tg1    service_p1
    check_no_dhcp_option82    tg1    subscriber_p1
    Tg Control Dhcp Client    tg1    ${group_name}    stop
    log    STEP:4 Modify the insertion policy to insert and repeat test. All DHCP messages are forwarded toward the server with the client inserted Opt82
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%Hostname
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    svc_vlan=${stag_vlan}    option82-action=insert
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:5 Capture entire DHCP transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should default to a format as Hostnameribed in the table above.
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname}
    check_no_dhcp_option82    tg1    subscriber_p1
    log    STEP:5 Modify the insertion policy to pass and repeat test. All DHCP messages are forwarded toward the server with the client inserted Opt82
    prov_interface    eutA    ont-ethernet    ${service_model.subscriber_point1.name}    svc_vlan=${stag_vlan}    option82-action=pass
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:5 Capture entire DHCP transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should default to a format as Hostnameribed in the table above.
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
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id
