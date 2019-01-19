*** Settings ***
Documentation     delete a non-existing id-profile
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***

*** Test Cases ***
tc_delete_a_non_existing_id_profile
    [Documentation]    delete a non-existing id-profile
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2347    @globalid=2356909    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:delete a non-existing id-profile
    ${res}    Run Keyword And Ignore Error    delete_config_object    eutA    id-profile    ${id_prf3}
    should contain    ${res[1]}    Error
*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    setup


case teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown