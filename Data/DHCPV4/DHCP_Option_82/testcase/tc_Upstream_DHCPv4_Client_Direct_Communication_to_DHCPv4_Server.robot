*** Settings ***
Documentation     Upstream DHCPv4 Client Direct Communication to DHCPv4 Server:  With a DHCP Server directly attached to the systems uplink.  Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the server.  -> Source MAC and source IP of the DHCP DISCOVER and DHCP REQUEST must be that of the client.
...    DHCPv4 Layer-2 Relay must support upstream communication directly with DHCP Servers.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Upstream_DHCPv4_Client_Direct_Communication_to_DHCPv4_Server
    [Documentation]    Upstream DHCPv4 Client Direct Communication to DHCPv4 Server:  With a DHCP Server directly attached to the systems uplink.  Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the server.  -> Source MAC and source IP of the DHCP DISCOVER and DHCP REQUEST must be that of the client.
    ...    DHCPv4 Layer-2 Relay must support upstream communication directly with DHCP Servers.
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2233    @globalid=2344049    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Upstream DHCPv4 Client Direct Communication to DHCPv4 Server: With a DHCP Server directly attached to the systems uplink. Force a DHCP client at the subscriber to obtain an IP address capturing the conversation at the server. -> Source MAC and source IP of the DHCP DISCOVER and DHCP REQUEST must be that of the client.
    log    STEP:DHCPv4 Layer-2 Relay must support upstream communication directly with DHCP Servers.
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}
    start_capture    tg1    service_p1
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    stop_capture    tg1    service_p1
    save_and_analyze_packet_on_port    tg1    service_p1    bootp


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