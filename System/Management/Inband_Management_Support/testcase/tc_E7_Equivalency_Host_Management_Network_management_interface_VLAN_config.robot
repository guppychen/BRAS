*** Settings ***
Documentation     IPV4 configuration is supported for:
...    IP Address, Net Mask, optional Gateway DHCP
...    For Network IP access a vlan and dotp priority are required.  No vlan configuration is require for the Craft interface which is untagged.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_E7_Equivalency_Host_Management_Network_management_interface_VLAN_config.robot
    [Documentation]
    ...    1 From the console port display the network interface port
    ...    the port should not default to vlan 999
    ...    2 enter config mode and configure the port with an ip address, netmask, vlan, .p and enable the port. show the interface
    ...    the config should take and the port should show the configured ip, netmask, vlan and .p
    ...    3 configure a tagged ethernet port on the DUT using the network interface VLAN, Connect to a device running wireshark
    ...    the port should be configured
    ...    4 issue a ping from the DUT
    ...    the wireshark trace should capture the pack and show the correctly configured vlan
    ...    5 reconfigure the VLAN on the network interface as well as the ethernet port to a new vlan
    ...    the config should take
    ...    6 issue a ping from the DUT
    ...    the wireshark trace should capture the pack and show the correctly configured vlan
    ...    7 repeated steps 5 and 6 multiple times
    ...    the vlan should always be correctly configured
    [Tags]   dual_card_not_support       @author=Ronnie_Yi    @TCID=AXOS_E72_PARENT-TC-2936    @globalid=2391509    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI   dual_card_not_support
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP4:issue a ping from the DUT
    wait until keyword succeeds  10   60   send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_fail    n1_console    ${ping_id_differ_segment}
    prov_ip_route    n1_console    ${next_hop_ip_address}
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}
    log    STEP5:reconfigure the VLAN on the network interface as well as the ethernet port to a new vlan
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1     ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    prov_interface_vlan    n1_console    ${vlan_id2}    ${ip_address}    ${prefix}
    service_point_add_vlan    service_point_list1    ${vlan_id2}
    log    STEP6:issue a ping from the DUT
    wait until keyword succeeds  10   60   send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_fail    n1_console    ${ping_id_differ_segment}
    prov_ip_route    n1_console    ${next_hop_ip_address}
    wait until keyword succeeds  10   60  send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP2:enter config mode and configure the port with an ip address, netmask, vlan, .p and enable the port. show the interface
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    log    STEP3:configure a tagged ethernet port on the DUT using the network interface VLAN, Connect to a device running wireshark
    service_point_add_vlan    service_point_list1    ${vlan_id}



case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    dprov_ip_route    n1_console    ${next_hop_ip_address}
    run keyword and ignore error    service_point_remove_vlan    service_point_list1    ${vlan_id}
    run keyword and ignore error    dprov_interface_vlan    n1_console    ${vlan_id}
    run keyword and ignore error    dprov_vlan    n1_console    ${vlan_id}
    run keyword and ignore error    service_point_remove_vlan    service_point_list1    ${vlan_id2}
    run keyword and ignore error    dprov_interface_vlan    n1_console    ${vlan_id2}
    run keyword and ignore error    dprov_vlan    n1_console    ${vlan_id2}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}
