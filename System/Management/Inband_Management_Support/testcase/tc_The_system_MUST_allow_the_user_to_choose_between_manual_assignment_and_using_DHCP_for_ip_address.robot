*** Settings ***
Documentation     MUST allow an IP address to be assigned to the management VLAN.
...    The system MUST allow the user to choose between manual assignment and using DHCP.
...    For this release, only IPV4 is required.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_system_MUST_allow_the_user_to_choose_between_manual_assignment_and_using_DHCP_for_ip_address
    [Documentation]    1	configure static ip to interface vlan 600	can ping pc on the same subnet and different subnet
    ...    2	configure dhcp to get ip for interface vlan	can get ip address ,and can ping pc on the same subnet and different subnet
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2941    @globalid=2391514    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 configure static ip to interface vlan 600 can ping pc on the same subnet and different subnet
    # add by llin work around for Cafe-3085 @2017.10.17
    wait until keyword succeeds  60  10   Disconnect     eutB
    # add by llin work around for Cafe-3085 @2017.10.17
    send_ping_and_check_no_loss    eutB    ${ping_id_same_segment}
    send_ping_and_check_no_loss    eutB    ${ping_id_differ_segment}
    log    STEP:2 configure dhcp to get ip for interface vlan can get ip address ,and can ping pc on the same subnet and different subnet
    change_interface_vlan_ip    n1_console    ${vlan_id}    dhcp=Yes
    wait until keyword succeeds    ${wait_until_dhcp_session_up}    20    check_interface_vlan_Dynamic_ip    n1_console    ${vlan_id}
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    service_point_add_vlan    service_point_list1    ${vlan_id}
    prov_ip_route    n1_console    ${next_hop_ip_address}

case teardown
    [Documentation]    case teardown
    [Arguments]
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1    ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}