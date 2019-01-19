*** Settings ***
Documentation     DHCP-R-230 The DHCPv4 Relay must enforce the 63 byte limit when the Circuit ID is TR-101 compliant.
...    This requirement is a corollary to requirement DHCP-R-3 above.
...    ======== CLI ==========
...     con
...     profile id-profile PROFId1
...     circuit-id "123456789012345678901234567890123456789012345678901234567890/%QTag/%CTag/%STag"
...     remote-id "RID-%MAC-%STag/%CTag"
...     top
...     profile dhcp-profile dhcpProf1
...     id-name PROFId1
...     top
...    ====== DCLI Commands ============
...    dcli l2hostmgrd add dhcp_profile dp402
...    dcli l2hostmgrd set vlan 402 dhcp_profile dp402
...    dcli l2hostmgrd set vlanport vlan 402 interface g15 dhcpdir client
...    dcli l2hostmgrd add id_profile idprof_1
...    dcli l2hostmgrd set id_profile idprof_1 circuit_id "12345678901234567890123456789012345678901234567890 1234567890 "/% Q Tag/% C Tag/ %STag
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_Byte_size_limit
    [Documentation]    1	Enable L2 relay and option 82	DHCP relay supporting option 82 insertion/removal enabled.
    ...    2	Set circuit ID to atleast 63 bytes long (63chars)	Circuit ID should allow contain 63 chars.
    ...    3	Force a subscriber to obtain an IP address via DHCP	Subscriber sends DHCP request and recieved an IP address.
    ...    4	Capture the transaction between the DHCP server and relay agent.	The circuit ID should be in the specified format.
    ...    5	set circuit ID to a value greater than 63 characters long.	only less than 63 characters can be inserted in packets
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2215    @globalid=2344031    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable L2 relay and option 82 DHCP relay supporting option 82 insertion/removal enabled.
    log    STEP:2 Set circuit ID to atleast 63 bytes long (63chars) Circuit ID should allow contain 63 chars.
    log    STEP:3 Force a subscriber to obtain an IP address via DHCP Subscriber sends DHCP request and recieved an IP address.
    log    STEP:4 Capture the transaction between the DHCP server and relay agent. The circuit ID should be in the specified format.
    log    STEP:5 set circuit ID to a value greater than 63 characters long. only less than 63 characters can be inserted in packets
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    check_dhcp_option82_circuit_id    tg1    service_p1    ${circuit_id}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=1234567890123456789012345678901234567890123456789012345678901234567890

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id