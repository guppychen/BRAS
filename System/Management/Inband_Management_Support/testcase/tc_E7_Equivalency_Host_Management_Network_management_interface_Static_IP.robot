*** Settings ***
Documentation     IPV4 configuration is supported for:
...      IP Address, Net Mask, optional Gateway
...      DHCP
...    For Network IP access a vlan and dotp priority are required.  No vlan configuration is require for the Craft interface which is untagged.
...    This test case covers the ability to configure the network interface with a static ip address
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_E7_Equivalency_Host_Management_Network_management_interface_Static_IP
    [Documentation]
    ...    1 From the console port display the network interface port
    ...    the port should be un-configured
    ...    2 enter config mode and configure the port with an ip address, netmask, vlan, .p and enable the port. show the interface
    ...    the config should take and the port should show the configured ip, netmask, vlan and .p
    ...    3 attach the host port to the configured network ping device on the same network
    ...      the ping should be successfu
    ...    4 ping an address on another network
    ...    the ping should fail
    ...    5 add a default GW to the network port and display the interface
    ...    the gateway should be configure
    ...    6 ping an address on another network
    ...    the ping should be successful
    ...    7 save the config and reload
    ...    the DUT should come up with the saved config and work correctly
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2934     @globalid=2391507    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP3:attach the host port to the configured network ping device on the same network
     wait until keyword succeeds    30   10    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    log    STEP4:ping an address on another network
    send_ping_and_check_fail    n1_console    ${ping_id_differ_segment}
    log    STEP5:add a default GW to the network port and display the interface
    prov_ip_route    n1_console    ${next_hop_ip_address}
    log    STEP6:ping an address on another network
    send_ping_and_check_no_loss    n1_console    ${ping_id_same_segment}
    send_ping_and_check_no_loss    n1_console    ${ping_id_differ_segment}
    log    STEP7:save the config and reload
    sleep   10   wait for inband ip ready
    run keyword and continue on failure  Disconnect     eutB
    Reload System    eutB
    send_ping_and_check_no_loss    eutB    ${ping_id_same_segment}
    send_ping_and_check_no_loss    eutB    ${ping_id_differ_segment}

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP2:enter config mode and configure the port with an ip address, netmask, vlan, .p and enable the port. show the interface
    Axos Cli With Error Check    n1_console    paginate false
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    service_point_add_vlan    service_point_list1     ${vlan_id}

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    cli    n1_console    sysadmin    retry=0    timeout=0    timeout_exception=0
    run keyword and ignore error    cli    n1_console    sysadmin    retry=0    timeout=0    timeout_exception=0
    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    cli
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    run keyword and ignore error    Axos Cli With Error Check    n1_console    ${EMPTY}
    Axos Cli With Error Check    n1_console    paginate false
    Axos Cli With Error Check    n1_console    idle-time 0
    dprov_ip_route    n1_console    ${next_hop_ip_address}
    service_point_remove_vlan    service_point_list1     ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan    n1_console    ${vlan_id}
    Copy Running Config To Startup Config      n1_console
    disconnect    n1_console
    sleep    ${wait_until_session_logout}
