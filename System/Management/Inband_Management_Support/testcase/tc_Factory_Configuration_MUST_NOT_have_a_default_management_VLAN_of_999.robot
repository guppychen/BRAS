*** Settings ***
Documentation     The factory Configuration MUST NOT have a default management VLAN of 999.
...
...
...
...    The previous DPU setting of having a default management VLAN MUST be  removed, so that the system initializes without in-band management configured.
...
...
...
...    This will be configured as part of the ZTP process, or will be configured thorugh a local managent interface.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Factory_Configuration_MUST_NOT_have_a_default_management_VLAN_of_999
    [Documentation]    1	show vlan 	no vlan 999 is existed for interface vlan
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2939    @globalid=2391512    @subfeature=Inband_Management_Support    @feature=Management    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 show vlan no vlan 999 is existed for interface vlan
    check_interface_up    n1_console  vlan      999
#    ${tmp}    cli    n1_console    show interface vlan 999
#    should contain    ${tmp}    vlan 999


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    login


case teardown
    [Documentation]    case teardown
    [Arguments]
    disconnect    n1_console
    sleep    ${wait_until_session_logout}