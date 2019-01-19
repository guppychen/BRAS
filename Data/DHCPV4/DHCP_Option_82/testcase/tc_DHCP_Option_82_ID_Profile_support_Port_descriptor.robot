*** Settings ***
Documentation     DHCP-R-228 Calix DHCPv4 Relay must support insertion of the port descriptor string of the port on which the DHCP request was received into the Remote ID.
...
...    ========== DCLI Commands ====================
...
...    dcli l2hostmgrd set interface g15 description "HOCH-port"
...
...    dcli l2hostmgrd set vlan 401 dhcp_mode snoop option82_remote "Hoch's_RD_with_PortDescription" -%Desc
...
...    dcli l2hostmgrd set vlanport vlan 401 interface g15 dhcpdir client
...
...    dcli l2hostmgrd set vlanport vlan 401 interface x2 dhcpdir server
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_Option_82_ID_Profile_support_Port_descriptor
    [Documentation]    1	Enable L2 relay agent and option 82	DHCP relay supporting option 82 insertion/removal enabled.
    ...    2	Set the circuit ID and remote ID to insert the port descriptor on which the DHCP request is received from subscriber.	Circuit ID and Remote ID string include port descriptors
    ...    3	Force a subscriber to obtain an IP address via DHCP	Subscriber sends DHCP request and receives an IP address.
    ...    4	Capture the transaction between the relay agent and DHCP server.	Circuit ID and Remote ID should be in the format specified.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2227    @globalid=2344043    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Enable L2 relay agent and option 82 DHCP relay supporting option 82 insertion/removal enabled.
    log    STEP:2 Set the circuit ID and remote ID to insert the port descriptor on which the DHCP request is received from subscriber. Circuit ID and Remote ID string include port descriptors
    log    STEP:3 Force a subscriber to obtain an IP address via DHCP Subscriber sends DHCP request and receives an IP address.
    log    STEP:4 Capture the transaction between the relay agent and DHCP server. Circuit ID and Remote ID should be in the format specified.
    configure_interface_ont_ethernet    eutA    ${service_model.subscriber_point1.name}   subscriber-id=${desc}
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    check_dhcp_option82_remote_id    tg1    service_p1    ${desc}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan
    prov_id_profile    eutA    ${id_profile_name}    remote-id=%Desc

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}
    delete_interface_ont_ethernet_configuration    eutA    ${service_model.subscriber_point1.name}    subscriber-id
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id