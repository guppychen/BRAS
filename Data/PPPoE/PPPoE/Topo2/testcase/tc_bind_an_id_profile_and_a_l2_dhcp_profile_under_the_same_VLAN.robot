*** Settings ***
Documentation     bind an id-profile and a l2-dhcp-profile under the same VLAN
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_bind_an_id_profile_and_a_l2_dhcp_profile_under_the_same_VLAN
    [Documentation]    bind an id-profile and a l2-dhcp-profile under the same VLAN
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2352    @globalid=2356914    @eut=NGPON2-4    @priority=P1
    [Setup]      setup
    [Teardown]   teardown
    log    bind an id-profile and a l2-dhcp-profile under the same VLAN
    prov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile=${dhcp_prf}    pppoe-ia-id-profile=${id_prf1}


*** Keywords ***
setup
    [Documentation]  setup
    log    profile provision
    prov_id_profile    eutA    ${id_prf1}
    prov_dhcp_profile    eutA    ${dhcp_prf}    option=id-name ${id_prf1}

teardown
    [Documentation]  teardown
    log    delete id-profile and dhcp_profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    l2-dhcp-profile    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_prf}
    delete_config_object    eutA    id-profile    ${id_prf1}


