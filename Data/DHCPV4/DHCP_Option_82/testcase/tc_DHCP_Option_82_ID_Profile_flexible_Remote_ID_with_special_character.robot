*** Settings ***
Documentation     DHCP-R-225 Calix DHCPv4 Relay must support flexible Remote ID specification as per the fields in Table 11. Field Name   Description   Rendered As   SystemID   The value of the SystemID must be configurable.   String (20 Char Max)   IfType   The defined values and their associated strings must include (at a minimum):   ADSL(2+) –"atm" ONT Ethernet – "ont" (non-standard) Ethernet – "eth" VDSL – "dsl" (non-standard) String (predefined values of no more than 3 char)   Node   This is the Calix equivalent of the rack number.   N#  (0 < # < 254)   Shelf   This is the shelf number where the port is located. This is equivalent to the chassis number used in E7 modular chassis.   Integer Valid range is defined by platform   Slot   This is the slot within the shelf where the port is located.   Integer (1-22)   Port   The port number on the slot or ONT. Port does  not  represent a PON port on an OLT.   Non-zero Integer (valid range is defined by the Technology)   VLAN   The VLAN number on the receive port associated with the Request message   All valid VLAN numbers <2 - 4094>   PRIO   The Ethernet Priority on the interface   <0-7> - This is only valid if the interface has a set priority for all traffic.   ONT   The number of the ONT on a given PON port   Non-zero Integer (valid range is defined by the PON type: GPON. BPON)   PON   The number of the PON on a given OLT   Non-zero Integer - Range is defined by platform   VPI   VPI number of an ATM endpoint (DSL/STS)   Valid VPI number   VCI   VCI number of an ATM endpoint (DSL/STS)   Valid VCI number   OID   Special string. This is used to render an endpoint's string from the port to completion based on the technology. This allows for a single definition to span various technologies (DSL. ONT-Eth. etc).   String (12 Char Max)   MAC   This renders the MAC address associated with a port. On an ONT Ethernet port. it is either the MAC of the ONT Ethernet Port itself. or the MAC of the RG to which the ONT port is connected. On an ADSL port. it is the MAC of the DSL modem or RG in the home.   Standard format MAC address (: separated)   SN   Serial Number – Many devices (ONT. RG) have a unique serial number (not a MAC) which is used to identify the device. FSAN serial number is just such an example.   String (16 Char MAX)   DESC   This renders the description string associated with a physical port   String (31 Char MAX)   Table  11  – Option 82 Format Values This test case verifies that when special characters such as '/'.'-'.'_'.'%'.' '.'?'  '.  etc. are given. it won't cause any adversary effect.   --- CLI ---       show running-config id-profile rid-mac  id-profile rid-mac  circuit-id %LabelPortNum.%PortNumber.%Port.%Serial.%OntID.%OntPort  remote-id  "REMOTEID-%SystemId-%MAC%%{+~.?#@_/^*" !
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_flexible_Remote_ID_with_special_character
    [Documentation]    1	Enable DHCP rely and option 82.	DHCP relay supporting option 82 insertion/removal enabled.
    ...    2	Configure Circuit ID and Remote ID field as defined in the specification above.	commands should be taken.
    ...    3	Force a subscriber to obtain an IP address via DHCP.	Subscriber sends DHCP response and obtains an IP address.
    ...    4	Capture entire DHCP transaction.	Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should be set to the specified format.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2228    @globalid=2344044    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable DHCP rely and option 82. DHCP relay supporting option 82 insertion/removal enabled.
    log    STEP:2 Configure Circuit ID and Remote ID field as defined in the specification above. commands should be taken.
    log    STEP:3 Force a subscriber to obtain an IP address via DHCP. Subscriber sends DHCP response and obtains an IP address.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    log    STEP:4 Capture entire DHCP transaction. Relay agent should insert sub options to the DHCP request received from subscriber and remove sub options before sending DHCP response back to subscriber. Circuit ID and Remote ID should be set to the specified format.
    stop_capture    tg1    service_p1
    ${mac}    get_ont_param    eutA    ${service_model.subscriber_point1.attribute.ont_id}    onu-mac-addr
    ${expect_mac}    convert to uppercase    ${mac}
    check_dhcp_option82_remote_id    tg1    service_p1    REMOTEID-${hostname}-${expect_mac}%{+~.?#@_/^*



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    remote-id="REMOTEID-%SystemId-%MAC%%{+~.?#@_/^*"

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id