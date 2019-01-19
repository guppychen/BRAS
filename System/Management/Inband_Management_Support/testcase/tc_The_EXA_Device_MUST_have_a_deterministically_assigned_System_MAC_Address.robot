*** Settings ***
Documentation     IPV4 configuration is supported for:
...    IP Address, Net Mask, optional Gateway DHCP
...    For Network IP access a vlan and dotp priority are required.  No vlan configuration is require for the Craft interface which is untagged.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_EXA_Device_MUST_have_a_deterministically_assigned_System_MAC_Address
    [Documentation]
    ...    1configure interface vlan 600 and show interface vlan 600
    ...    mac-addr should be the same as card mac
    [Tags]       @author=Yeast Jiang     @TCID=AXOS_E72_PARENT-TC-2938    @globalid=2391511    @eut=NGPON2-4    @priority=p1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:mac-addr should be the same as card mac
    check_interface_vlan_mac_address    n1_console    ${vlan_id}



*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    STEP:configure interface vlan 600 and show interface vlan 600
    prov_interface_vlan    n1_console    ${vlan_id}    ${ip_address}    ${prefix}
    service_point_add_vlan    service_point_list1     ${vlan_id}



case teardown
    [Documentation]     case teardown
    [Arguments]
    service_point_remove_vlan    service_point_list1     ${vlan_id}
    dprov_interface_vlan    n1_console    ${vlan_id}
    dprov_vlan   n1_console  ${vlan_id}
    disconnect    n1_console
    sleep    ${wait_until_session_logout}
