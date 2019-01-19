*** Settings ***
Documentation     create an id-profile and set a circuit-id and a remote-id
Resource          ./base.robot
Force Tags        @feature=pppoe    @subfeature=pppoe    @author=joli

*** Variables ***


*** Test Cases ***
tc_create_an_id_profile_and_set_a_circuit_id_and_a_remote_id
    [Documentation]    create an id-profile and set a circuit-id and a remote-id
    [Tags]       @author=joli     @tcid=AXOS_E72_PARENT-TC-2346    @globalid=2356908    @eut=NGPON2-4    @priority=P2
    [Setup]      case setup
    [Teardown]   case teardown
    log    show running id-profile
    check_running_configure    eutA    id-profile    ${id_prf1}    circuit-id=aaa    remote-id=bbb



*** Keywords ***
case setup
    [Documentation]  setup
    [Arguments]
    log    create an id-profile
    prov_id_profile    eutA    ${id_prf1}    circuit-id=aaa    remote-id=bbb


case teardown
    [Documentation]  teardown
    [Arguments]
    log    delete id-profile under vlan
    delete_config_object    eutA    id-profile    ${id_prf1}
