*** Settings ***
Documentation     bind an id-profile under VLAN
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_bind_an_id_profile_under_VLAN
    [Documentation]    bind an id-profile under VLAN
    [Tags]    @author=joli    @tcid=AXOS_E72_PARENT-TC-2349    @globalid=2356911    @eut=NGPON2-4    @priority=P1
    [Setup]    setup
    log    STEP:bind an id-profile under VLAN
    log    bind a non-exist id-profile under VLAN
    ${res}    Run Keyword And Ignore Error    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf3}
    should contain    ${res[1]}    failed to apply modifications
    log    bind an existing id-profile under VLAN
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    log    id-profile provision
    prov_id_profile    eutA    ${id_prf1}

teardown
    [Documentation]    teardown
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    id-profile    ${id_prf1}
