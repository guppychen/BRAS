*** Settings ***
Documentation     IP Address, Net Mask, optional Gateway
...      DHCP
...    For Network IP access a vlan and dotp priority are required.  No vlan configuration is require for the Craft interface which is untagged.
...    #################################################################################
...    This test case covers the ability of the network management interface to DHCP an address
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_E7_Equivalency_Host_Management_Network_management_interface_DHCP
    [Documentation]    1	From the console port display the network management interface 	verify that the default config un-provisioned. there should be no ip, vlan or .p
    ...    2	Enter config mode for the interface and configure the VLAN, the .p, mode DHCP and enable it. Show the interface	the config should take and the port should show the configure vlan and .p. The mode should be set to DHCP.
    ...    3	Configure a DHCP server that hands back an ip address, netmask and default GW
    ...    4	configure the DUT to have access to a DHCP server on the configure network interface VLAN. this could be an untagged port to the network or via an ERPS ring.
    ...    5	show the network interface 	the interface should have successfully DHCP'ed an address with an IP, netmask and GW
    ...    6	From the DUT verify ping another device on the same network	this should be sucessfully
    ...    7	From the DUT verify ping another device on a different network 	the ping should be successful
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2932    @globalid=2391505    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 From the console port display the network management interface verify that the default config un-provisioned. there should be no ip, vlan or .p
    log    STEP:2 Enter config mode for the interface and configure the VLAN, the .p, mode DHCP and enable it. Show the interface the config should take and the port should show the configure vlan and .p. The mode should be set to DHCP.
    log    STEP:3 Configure a DHCP server that hands back an ip address, netmask and default GW
    log    STEP:4 configure the DUT to have access to a DHCP server on the configure network interface VLAN. this could be an untagged port to the network or via an ERPS ring.
    log    STEP:5 show the network interface the interface should have successfully DHCP'ed an address with an IP, netmask and GW
    wait until keyword succeeds    ${wait_until_dhcp_session_up}    30    check_interface_vlan_Dynamic_ip    n1_console    ${vlan_id}
    log    STEP:6 From the DUT verify ping another device on the same network this should be sucessfully
    wait until keyword succeeds    30    10   send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    log    STEP:7 From the DUT verify ping another device on a different network the ping should be successful
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
    cli    n1_console   show ip route all

    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1     ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}