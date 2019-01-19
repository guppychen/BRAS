*** Settings ***
Documentation     DHCPv4 Snoop Agent MAC Address Insertion: Generate DHCP DISCOVERS from a client with the DHCP Server disabled.  Display learned MAC addresses.  Restart DHCP DISCOVERs with DHCP Server enabled to complete conversation.  Display learned MAC addresses.  -> The Client MAC address is not displayed until the DHCP conversation has been completed.
...
...
...
...    DHCPv4 Snoop Agent must provide MAC address insertion into the local bridge to allow operation without learning from untrusted interfaces
...
...
...    This is a requirement to support source MAC address insertion based on learned lease information.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCPv4_Snoop_Agent_MAC_Address_Insertion
    [Documentation]    1	send dhcp discover with serve disabled, show bridge table	no client mac
    ...    2	enable dhcp server ,and start dhcp process, show bridge table	can show client mac as static mac
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-699    @globalid=2307039    @subfeature=DHCP_Snoop_IPv4    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1
    [Setup]      case setup
    [Teardown]   case teardown
#    log    STEP:1 send dhcp discover with serve disabled, show bridge table no client mac
    log    get dhcp lease and check
    Axos Cli With Error Check    eutA    clear bridge table
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    lease_time=${lease_time}
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ${Qtag_vlan}

    Tg Control Dhcp Client    tg1    ${group_name}    start
    log    show dhcp leases and check bridge table
    check_l3_hosts    eutA    0
    check_bridge_table_no_entry    eutA
    tg save config into file    tg1   /tmp/dddddd.xml
#    Tg Control Dhcp Client    tg1    ${group_name}    stop

    clear_interface_counters    eutA      ${service_model.service_point1.type}      ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA      ${service_model.subscriber_point1.attribute.interface_type}      ${service_model.subscriber_point1.member.interface1}

    sleep   20s  wait for mac clear
    log    STEP:2 enable dhcp server ,and start dhcp process, show bridge table can show client mac as static mac
    Tg Control Dhcp Server    tg1    ${server_name}    start

    wait until keyword succeeds    5x   10s   debug step for the case
#    Tg Control Dhcp Server    tg1    ${server_name}    start
#    Tg Control Dhcp Client    tg1    ${group_name}    start
#
#    log   add debug for AT-3404
#
#    show_interface_counters   eutA      ${service_model.service_point1.type}      ${service_model.service_point1.member.interface1}
#    show_interface_counters   eutA      ${service_model.subscriber_point1.attribute.interface_type}      ${service_model.subscriber_point1.member.interface1}
#
#    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
#    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
#    check_bridge_table    eutA    ${client_mac}    learn=STATIC

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}    cevlan_action=remove-cevlan

case teardown
    [Documentation]    case teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan}    ${stag_vlan}


#   *******AT-3404**************add this step for debug
debug step for the case
#    [Teardown]     Tg Control Dhcp Client    tg1    ${group_name}    stop

    Tg Control Dhcp Client    tg1    ${group_name}    bind

    log   add debug for AT-3404

    show_interface_counters   eutA      ${service_model.service_point1.type}      ${service_model.service_point1.member.interface1}
    show_interface_counters   eutA      ${service_model.subscriber_point1.attribute.interface_type}      ${service_model.subscriber_point1.member.interface1}
#    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    check_bridge_table    eutA    ${client_mac}    learn=STATIC

