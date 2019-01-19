*** Settings ***
Documentation     IPV4 configuration is supported for:
...               IP Address, Net Mask, optional Gateway DHCP
...               For Network IP access a vlan and dotp priority are required. No vlan configuration is require for the Craft interface which is untagged.
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_E7_Equivalency_Host_Management_Network_management_interface_Static_IP_reconfigure
   [Documentation]
    ...    1 From the console port display the network interface port
    ...    the port should be un-configured
    ...    2 enter config mode and configure the port with an ip address. netmask. vlan. priority and enable the port. show the interface
    ...    the config should take and the port should show the configured ip; netmask; vlan and .p
    ...    3 attach the host port to the configured network ping device on the same network
    ...    the ping should be successful
    ...    4 ping an address on another network
    ...    the ping should fail
    ...    5 add a default GW to the network port and display the interface
    ...    the gateway should be cofigured
    ...    6 ping an address on another network
    ...    the ping should be successful
    ...    7 reconfigure the network interface with a new ip on the same subent and show the port
    ...    the new ip address should be configured
    ...    8 ping address on the same subnet
    ...    the ping should be successful
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2935    @globalid=2391508    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP4:ping an address on another network
    wait until keyword succeeds  60  10  send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_fail    n1_console    ${ping_id_differ_segment}
    log    STEP5:add a default GW to the network port and display the interface
    prov_ip_route    n1_console    ${next_hop_ip_address}
    log    STEP6:ping an address on another network
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}
    log    STEP7:reconfigure the network interface with a new ip on the same subent and show the port
    change_interface_vlan_ip    n1_console    ${vlan_id}    ${ip_address2}    ${prefix}
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    log    STEP8:ping address on the same subnet
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_fail    n1_console    ${ping_id_differ_segment}
    prov_ip_route    n1_console    ${next_hop_ip_address}
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP2:enter config mode and configure the port with an ip address. netmask. vlan. priority and enable the port. show the interface
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    log    STEP3:attach the host port to the configured network ping device on the same network
    service_point_add_vlan    service_point_list1    ${vlan_id}

case teardown
    [Documentation]    case teardown
    [Arguments]
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1    ${vlan_id}
    run keyword and ignore error    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}
