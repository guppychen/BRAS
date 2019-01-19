*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Apply_IGMP_profile_to_VLAN
    [Documentation]    1	Apply it to VLAN with IGMP mode as proxy mode	Action succeed and can be retrieved from VLAN detail show for configuration version and operation version
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2239    @GlobalID=2346506
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Apply it to VLAN with IGMP mode as proxy mode Action succeed and can be retrieved from VLAN detail show for configuration version and operation version
    prov_igmp_profile    eutA    ${p_igmp_profile_test}    auto
    prov_vlan    eutA    ${p_igmp_vlan}    igmp-profile=${p_igmp_profile_test}
    ${result}    cli    eutA    show running-config vlan ${p_igmp_vlan}
    should match regexp    ${result}    igmp-profile\\s+${p_igmp_profile_test}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2239 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2239 teardown
    delete_config_object    eutA    vlan    ${p_igmp_vlan}
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile_test}