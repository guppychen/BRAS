*** Settings ***
Documentation     delete an id-profile that has been used under VLAN
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_delete_an_id_profile_that_has_been_used_under_VLAN
    [Documentation]    delete an id-profile that has been used under VLAN
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2350    @globalid=2356912    @eut=NGPON2-4    @priority=P1
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:delete an id-profile that has been used under VLAN
    ${res}    Run Keyword And Ignore Error    delete_config_object    eutA    id-profile    ${id_prf1}
    should contain    ${res[1]}    Error

*** Keywords ***
setup
    [Documentation]  setup
    log    id-profile provision
    prov_id_profile    eutA    ${id_prf1}

    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}

teardown
    [Documentation]  teardown
    log    delete id-profile under vlan
    dprov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    id-profile    ${id_prf1}
