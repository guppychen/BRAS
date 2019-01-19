*** Settings ***
Documentation      IPV4 configuration is supported for:
...
...
...
...      IP Address, Net Mask, optional Gateway
...      DHCP
...
...
...    For Network IP access a vlan and dotp priority are required.  No vlan configuration is require for the Craft interface which is untagged.
...
...
...
...    #################################################################################
...
...    This test case covers the ability to change the network interface between static and dhcp addresses
...
...
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_E7_Equivalency_Host_Management_Network_management_interface_reconfig_DHCP_Static
    [Documentation]    1	From the console port display the network management interface 	verify that the default config default vlan is 999
    ...    2	Enter config mode for the interface and configure the VLAN, the .p, mode DHCP and enable it. Show the interface	the config should take and the port should show the configure vlan and .p. The mode should be set to DHCP.
    ...    3	Configure a DHCP server that hands back an ip address, netmask and default GW	the dhcp server should be configured
    ...    4	configure the DUT to have access to a DHCP server on the configure network interface VLAN. this could be an untagged port to the network or via an ERPS ring.	the DUT should be configured
    ...    5	show the network interface 	the interface should have successfully DHCP'ed an address with an IP, netmask and GW
    ...    6	Ping a device on the same network	the ping should be successful
    ...    7	reconfigure the netowrk interface to have a static ip, netmask and GW with a different ip on the same subnet. show the interface	the config should take and the display should show the newly configured static IP
    ...    8	Ping a device on the same network	the ping should be successful
    ...    9	reconfigure the network interface to DHCP its address and show the interface	the config should take and the DUT should DHCP its address again
    ...    10	Ping a device on the same network	the ping should be successful
    ...    11	repeat steps 7-10	they should be successful
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2937    @globalid=2391510    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 From the console port display the network management interface verify that the default config default vlan is 999
    log    STEP:2 Enter config mode for the interface and configure the VLAN, the .p, mode DHCP and enable it. Show the interface the config should take and the port should show the configure vlan and .p. The mode should be set to DHCP.
    log    STEP:3 Configure a DHCP server that hands back an ip address, netmask and default GW the dhcp server should be configured
    log    STEP:4 configure the DUT to have access to a DHCP server on the configure network interface VLAN. this could be an untagged port to the network or via an ERPS ring. the DUT should be configured
    log    STEP:5 show the network interface the interface should have successfully DHCP'ed an address with an IP, netmask and GW
    wait until keyword succeeds    ${wait_until_dhcp_session_up}    20    check_interface_vlan_Dynamic_ip    n1_console    ${vlan_id}
    log    STEP:6 Ping a device on the same network the ping should be successful
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}
    log    STEP:7 reconfigure the netowrk interface to have a static ip, netmask and GW with a different ip on the same subnet. show the interface the config should take and the display should show the newly configured static IP
    change_interface_vlan_ip    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    log    STEP:8 Ping a device on the same network the ping should be successful
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}
    log    STEP:9 reconfigure the network interface to DHCP its address and show the interface the config should take and the DUT should DHCP its address again
    change_interface_vlan_ip    n1_console    ${vlan_id}    dhcp=Yes
    wait until keyword succeeds    ${wait_until_dhcp_session_up}    20    check_interface_vlan_Dynamic_ip    n1_console    ${vlan_id}
    log    STEP:10 Ping a device on the same network the ping should be successful
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    log    STEP:11 repeat steps 7-10 they should be successful
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    prov_interface_vlan    n1_console    ${vlan_id}    dhcp=Yes
    service_point_add_vlan    service_point_list1     ${vlan_id}
    prov_ip_route    n1_console    ${next_hop_ip_address}

case teardown
    [Documentation]    case teardown
    [Arguments]
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1     ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}