*** Settings ***
Documentation     create an id-profile with a name and show it
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_create_an_id_profile_with_a_name_and_show_it
    [Documentation]    create an id-profile with a name and show it
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2345    @globalid=2356907    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    show it
    check_running_configure    eutA    id-profile    ${id_prf1}

*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    create an id-profile
    prov_id_profile    eutA    ${id_prf1}

case teardown
    [Documentation]  teardown
    [Arguments]
    log    delete id-profile under vlan
    delete_config_object    eutA    id-profile    ${id_prf1}
