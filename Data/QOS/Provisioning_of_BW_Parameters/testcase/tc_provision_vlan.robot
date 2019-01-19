*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision VLAN works.
*** Variables ***

*** Test Cases ***
tc_provision_vlan
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision vlan, confirm VLAN provision works.		
    ...    2	Provision various parameters, child object under VLAN, confirm the provision works.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1002    @globalid=2316464    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1002 setup
    [Teardown]   AXOS_E72_PARENT-TC-1002 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision vlan, confirm VLAN provision works.

    log    STEP:2 Provision various parameters, child object under VLAN, confirm the provision works.

    log    provision dhcp profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}

    log    provision vlan
    prov_vlan    eutA    ${p_match_vlan1}    l2-dhcp-profile=${dhcp_profile_name}    mac-learning=enable
    check_running_configure_vlan    eutA    ${p_match_vlan1}    l2-dhcp-profile=${dhcp_profile_name}




*** Keyword ***
AXOS_E72_PARENT-TC-1002 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1002 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove vlan
    delete_config_object    eutA    vlan    ${p_match_vlan1}
    log    remove dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_profile_name}


