*** Settings ***
Documentation     DHCP-R-227 Calix DHCPv4 Relay must support insertion of the MAC address of the port on which the DHCP request was received in binary as a 6 byte value into the Remote ID. This is required for DOCSIS consistency.

...    == CLI ===

...    conf
...
...    profile id-profile  idprof401
...
...    circuit-id "rid_idprof401-%BinaryMAC"
...
...    remote-id "rid_idprof401-%BinaryMAC"
...
...    top
...
...    ===== DCLI  Commands =========
...
...    dcli l2hostmgrd set interface g15 mac 00:01:02:03:04:15
...
...    dcli l2hostmgrd set vlan 401 dhcp_mode snoop option82_remote "Hoch's RD with PortMACinBinary"-%BinaryMAC
...
...    dcli l2hostmgrd set vlanport vlan 401 interface g15 dhcpdir client
...
...    dcli l2hostmgrd set vlanport vlan 401 interface x2 dhcpdir server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_insert_MAC_as_6_byte
    [Documentation]    1	enable DHCP L2 relay and option 82	DHCP relay supporting option 82 insertion/removal enabled
    ...    2	set circuit id and remote id to insert the MAC address of the port on which subscriber is on.	specific circuit id set
    ...    3	force a subscriber to obtain an IP address via DHCP	subscriber obtains IP
    ...    4	Capture the the tranaction between the DHCP server and relay agent.	Relay agent should insert sub options to the DHCP request received from subscriber. Circuit ID and Remote ID should insert the MAC address of the port on subscriber is on.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2216    @globalid=2344032    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 enable DHCP L2 relay and option 82 DHCP relay supporting option 82 insertion/removal enabled
    log    STEP:2 set circuit id and remote id to insert the MAC address of the port on which subscriber is on. specific circuit id set
    log    STEP:3 force a subscriber to obtain an IP address via DHCP subscriber obtains IP
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:4 Capture the the tranaction between the DHCP server and relay agent. Relay agent should insert sub options to the DHCP request received from subscriber. Circuit ID and Remote ID should insert the MAC address of the port on subscriber is on.
    stop_capture    tg1    service_p1
    ${mac}    get_ont_param    eutA    ${service_model.subscriber_point1.attribute.ont_id}    onu-mac-addr
    ${expect}    convert to uppercase    ${mac}
    check_dhcp_option82_circuit_id    tg1    service_p1    ${expect}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    circuit-id=%MAC


case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=circuit-id