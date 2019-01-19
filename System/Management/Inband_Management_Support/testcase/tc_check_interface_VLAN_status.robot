*** Settings ***
Documentation      MUST allow an operator to show the status of the management VLAN.
...    The status MUST include the following:
...        VLAN id
...        IP address
...        Mac Address
...        Oper status
...        last-change time
...        Rx and Tx packets, octets, discards and errors
...        DHCP client identifier
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_check_interface_VLAN_status
    [Documentation]    1	show interface vlan 600 status	include those info as description
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2940    @globalid=2391513    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 show interface vlan 600 status include those info as description
    wait until keyword succeeds    5min    10    check_interface_vlan_status    eutB    ${vlan_id}    ${ip_address}    ${prefix}


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
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
