*** Settings ***
Documentation     Downstream DHCPv4 Server Direct Communication to DHCP Client:  With a DHCP Server directly attached to the systems uplink.  Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the client.  -> Source MAC and source IP of the DHCP OFFER and DHCP ACK must be that of the server.
...    DHCPv4 Layer-2 Relay must support downstream communication directly with DHCP Clients.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Downstream_DHCPv4_Server_Direct_Communication_to_DHCPv4_Client
    [Documentation]    Downstream DHCPv4 Server Direct Communication to DHCP Client:  With a DHCP Server directly attached to the systems uplink.  Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the client.  -> Source MAC and source IP of the DHCP OFFER and DHCP ACK must be that of the server.
    ...
    ...
    ...
    ...    DHCPv4 Layer-2 Relay must support downstream communication directly with DHCP Clients.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2232    @globalid=2344048    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Downstream DHCPv4 Server Direct Communication to DHCP Client: With a DHCP Server directly attached to the systems uplink. Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the client. -> Source MAC and source IP of the DHCP OFFER and DHCP ACK must be that of the server.
    log    STEP:DHCPv4 Layer-2 Relay must support downstream communication directly with DHCP Clients.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    subscriber_p1
    save_and_analyze_packet_on_port    tg1    subscriber_p1    bootp


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