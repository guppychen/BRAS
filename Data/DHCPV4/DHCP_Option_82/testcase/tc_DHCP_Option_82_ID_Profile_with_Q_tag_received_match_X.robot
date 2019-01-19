*** Settings ***
Documentation     DHCP-R-208 All Calix DHCP Relay or Snoop supporting Option 82 insertion of a TR-101 or TR-156 compliant Circuit ID must set the VLAN value to the Q-tag of the received frame.
...
...
...
...    It should be noted that while this is not intuitive. it is the defined standard behavior.
...
...
...
...    This test case verifies that by default. circuit ID uses Q-Tag as vlan is the default format. It also verifies that when option82 circuit ID is set to include %QTag. Q-tag will be included in circuit ID.
...
...    ===========
...
...    This test case verifies that ingress X. matchrule X->Y test scenario. QTag should be X.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_with_Q_tag_received_match_X
    [Documentation]    1	Configure X->Y UNI service on port A.
    ...    2	Enable DHCP snoop on SVLAN Y.	Option 82 configuration enabled.
    ...    3	Set option82 CircuitID and Remote ID format to include %QTag.
    ...    4	Start capture on network side and subscriber side.
    ...    5	Bind a DHCP client on port A. Stop the capture in step2.
    ...    6	Examine the capture files.	subscriber side Discover and Request should not contain option82. network side Discover and Request message should contain option 82 with circuit ID and remote ID using received Q-tag as vlan.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2217    @globalid=2344033    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure X->Y UNI service on port A.
    log    STEP:2 Enable DHCP snoop on SVLAN Y. Option 82 configuration enabled.
    log    STEP:3 Set option82 CircuitID and Remote ID format to include %QTag.
    log    STEP:4 Start capture on network side and subscriber side.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    log    STEP:5 Bind a DHCP client on port A. Stop the capture in step2.
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    log    STEP:6 Examine the capture files. subscriber side Discover and Request should not contain option82. network side Discover and Request message should contain option 82 with circuit ID and remote ID using received Q-tag as vlan.
    check_dhcp_option82_circuit_id    tg1    service_p1    ${Qtag_vlan}
    stop_capture    tg1    subscriber_p1
    check_no_dhcp_option82    tg1    subscriber_p1



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%QTag

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id