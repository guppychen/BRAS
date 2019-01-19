*** Settings ***
Documentation     DHCP-R-206 All Calix DHCPv4 Relay or Snoop supporting Option 82 insertion/removal must default the format of the Circuit ID to a TR-101 compliant format for all DSL and Ethernet interfaces   type 4 ================================= DHCP Client ----- UNI A ---- snoop agent of EXA -------- INNI B ---- DHCP Server ======== current default fomat ======= %systemID eth :
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_Default_format_match_untag_add_c_tag_set_pcp_p1_untag_S_p1_C
    [Documentation]    1	Configure UNI service type 4 on UNI port A.
    ...    2	Enable DHCP Snoop on SVLAN X.	Option 82 configuration enabled
    ...    3	Set SystemID.
    ...    4	Force subscriber to obtain an IP address via DHCP.	Subscriber should send a DHCP request and receive and IP address.
    ...    5	Capture entire DHCP transaction.	Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should default to a format as described in the table above.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2226    @globalid=2344042    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure UNI service type 4 on UNI port A.
    log    STEP:2 Enable DHCP Snoop on SVLAN X. Option 82 configuration enabled
    log    STEP:3 Set SystemID.
    log    STEP:4 Force subscriber to obtain an IP address via DHCP. Subscriber should send a DHCP request and receive and IP address.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=${lease_time}    ovlan_pbit=${stag_pbit}    ivlan_pbit=${ctag_pbit}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    stop_capture    tg1    service_p1
    log    STEP:5 Capture entire DHCP transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should default to a format as described in the table above.
    ${type}    get_dhcp_option82_expected_port_type    subscriber_point1
    ${port}    get_dhcp_option82_exported_port    subscriber_point1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${hostname} ${type} ${port}:


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}    ctag_action=add-cevlan-tag    cvlan=${ctag_vlan}    set-cevlan-pcp=${ctag_pbit}    set-stag-pcp=${stag_pbit}
#    Cli With Error Check    eutA    perform ont reset ont-id ${service_model.subscriber_point1.attribute.ont_id}
#    sleep    ${wait_ont_come_back_in_reality}
case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}    cvlan=${ctag_vlan}