*** Settings ***
Documentation     remove the id-profile from VLAN
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_remove_the_id_profile_from_VLAN
    [Documentation]    remove the id-profile from VLAN
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2351    @globalid=2356913    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:remove the id-profile from VLAN
    dprov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile

*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    create an id-profile
    prov_id_profile    eutA    ${id_prf1}
    log    create a vlan
    prov_vlan    eutA    ${p_data_vlan}    pppoe-ia-id-profile=${id_prf1}


case teardown
    [Documentation]  teardown
    [Arguments]
    log    delete vlan and id-profile
    delete_config_object    eutA    vlan    ${p_data_vlan}
    delete_config_object    eutA    id-profile    ${id_prf1}

