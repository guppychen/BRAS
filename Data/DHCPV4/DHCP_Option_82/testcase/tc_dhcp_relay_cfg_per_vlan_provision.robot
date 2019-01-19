*** Settings ***
Documentation     dhcp relay cfg per vlan provision
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_dhcp_relay_cfg_per_vlan_provision
    [Documentation]    1	modify /delete when in used by vlan	modisy success/should not be deleted when in used by vlan
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-2203    @globalid=2344019    @subfeature=DHCP_Option_82    @feature=DHCPV4    @eut=NGPON2-4    @priority=P1    @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 modify /delete when in used by vlan modisy success/should not be deleted when in used by vlan
    prov_id_profile    eutA    ${id_profile_name}    remote-id=%Desc
    ${tmp}    Axos Cli With Error Check    eutA    show running-config id-profile ${id_profile_name}
    should match regexp    ${tmp}    remote-id  "$Desc"
    cli    eutA    configure
    ${tmp}    cli    eutA    no id-profile ${id_profile_name}
    should contain    ${tmp}    Error: failed to apply modifications
    cli   eutA    end

*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
   log    profile is created in suite setup

case teardown
    [Documentation]    case teardown
    [Arguments]
    run keyword and ignore error    cli   eutA    end
    dprov_id_profile    eutA    ${id_profile_name}    option=remote-id