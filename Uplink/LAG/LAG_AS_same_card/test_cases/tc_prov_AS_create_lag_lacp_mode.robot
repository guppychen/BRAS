*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_AS_create_lacp_mode
    [Documentation]    prov create lacp mode
    [Tags]    @globalid=2439405    @tcid=AXOS_E72_PARENT-TC-2987    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show inter la la1 status lacp-mode
    should contain    ${re}    ${lag_mode_active}
     lag_prov    eutA    la1    ${lag_mode_passive}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show inter la la1 status lacp-mode
    should contain    ${re}    ${lag_mode_passive}
     lag_prov    eutA    la1    ${lag_mode_none}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show inter la la1 status lacp-mode
    should contain    ${re}    ${lag_mode_none}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show inter la la1 status lacp-mode
    should contain    ${re}    ${lag_mode_active}

    # ${re}    configure    eutA    no inter la ${la4}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown

    