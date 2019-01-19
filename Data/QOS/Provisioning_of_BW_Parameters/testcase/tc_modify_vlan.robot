*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm modify VLAN works.\
*** Variables ***

*** Test Cases ***
tc_modify_vlan
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision vlan, confirm VLAN modification works, for various parameters, such as profile and security.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1003    @globalid=2316465    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1003 setup
    [Teardown]   AXOS_E72_PARENT-TC-1003 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision vlan, confirm VLAN modification works, for various parameters, such as profile and security.

    log    provision dhcp profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}

    log    provision igmp profile
    prov_igmp_profile    eutA    ${igmp_profile_name}

    log    provision vlan
    prov_vlan    eutA    ${p_match_vlan1}    l2-dhcp-profile=${dhcp_profile_name}    mac-learning=enable
    check_running_configure_vlan    eutA    ${p_match_vlan1}    l2-dhcp-profile=${dhcp_profile_name}

    log    modify vlan parameter
    prov_vlan    eutA    ${p_match_vlan1}    igmp-profile=${igmp_profile_name}
    check_running_configure_vlan    eutA    ${p_match_vlan1}    igmp-profile=${igmp_profile_name}

    prov_vlan    eutA    ${p_match_vlan1}    mff=ENABLED
    check_running_configure_vlan    eutA    ${p_match_vlan1}    mff=ENABLED



*** Keyword ***
AXOS_E72_PARENT-TC-1003 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1003 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove vlan
    delete_config_object    eutA    vlan    ${p_match_vlan1}
    log    remove dhcp profile
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_profile_name}
    delete_config_object    eutA    igmp-profile    ${igmp_profile_name}

