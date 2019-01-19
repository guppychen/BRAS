*** Settings ***
Documentation     create an id-profile with a name that has an illegal charactor
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_create_an_id_profile_with_a_name_that_has_an_illegal_charactor
    [Documentation]    create an id-profile with a name that has an illegal charactor
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2348    @globalid=2356910    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:create an id-profile with a name that has an illegal charactor
    ${res}    Run Keyword And Ignore Error    prov_id_profile    eutA    %$aa
    should contain    ${res[1]}    syntax error


*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    case setup


case teardown
    [Documentation]  teardown
    [Arguments]
    log    case teardown