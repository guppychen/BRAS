*** Settings ***
Documentation     DHCP-R-229 Calix DHCPv4 Relay must support insertion of the MAC address of the port on which the DHCP request was receive as a string in the standard format (xx:xx:xx:xx:xx:xx)
...
...    ====== DCLI Commands ====================
...
...      dcli l2hostmgrd set interface g15 mac 00:01:02:03:04:15  -- workaround to set port MAC
...
...     
...
...      dcli l2hostmgrd set vlan 401 dhcp_mode snoop option82_remote "RD_PortMAC"-%MAC   --- set remote ID to contain MAC
...
...      dcli l2hostmgrd set vlan 401 option82_variable "CircuitID"-%MAC ----- set option 82 circuit ID to contain MAC
...
...     
...
...      dcli l2hostmgrd set vlanport vlan 401 interface g15 dhcpdir client
...
...      dcli l2hostmgrd set vlanport vlan 40 1 interface x2 dhcpdir serve
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_MAC_in_standard_format
    [Documentation]    1	Enable DHCP relay and option 82	DHCP relay supporting option 82 insertion/removal enabled.
    ...    2	Set circuit ID and Remote ID to include MAC address of the port on which DHCP request was received. 	Relay will insert MAC address in standard fromat (xx:xx:xx:xx:xx:xx).
    ...    3	Force a subscriber to obtain an IP address via DHCP	Subscriber sends DHCP request message and receives an IP address.
    ...    4	Capture the transaction between the relay agent and DHCP server	The circuit ID and remote ID should be in the specified format.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2214    @globalid=2344030    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP relay and option 82 DHCP relay supporting option 82 insertion/removal enabled.
    log    STEP:2 Set circuit ID and Remote ID to include MAC address of the port on which DHCP request was received. Relay will insert MAC address in standard fromat (xx:xx:xx:xx:xx:xx).
    log    STEP:3 Force a subscriber to obtain an IP address via DHCP Subscriber sends DHCP request message and receives an IP address.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    log    STEP:4 Capture the transaction between the relay agent and DHCP server The circuit ID and remote ID should be in the specified format.
    ${mac}    get_ont_param    eutA    ${service_model.subscriber_point1.attribute.ont_id}    onu-mac-addr
    ${expect}    convert to uppercase    ${mac}
    check_dhcp_option82_circuit_id    tg1    service_p1    ${expect}
    check_dhcp_option82_remote_id    tg1    service_p1    ${expect}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%MAC
    prov_id_profile    eutA    ${id_profile_name}    remote-id=%MAC

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id