*** Settings ***
Resource          ./base.robot

*** Variables ***
${max_port_8}    8
${min_port_8}    8
${max_port}    1
${min_port}    1


*** Test Cases ***
tc_prov_AS_create_lag_max_min_port
    [Documentation]    prov create lag max min port
    [Tags]    @globalid=2439406    @tcid=AXOS_E72_PARENT-TC-2988    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show interface lag la1 configuration max-port
    should contain    ${re}    ${max_port}
    lag_prov    eutA    la1    ${lag_mode_passive}    ${max_port_8}    ${min_port_8}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show interface lag la1 configuration max-port
    should contain    ${re}    ${max_port_8}
    ${re}    cli    eutA    show interface lag la1 configuration min-port
    should contain    ${re}    ${min_port_8}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show interface lag la1 configuration max-port
    should contain    ${re}    ${max_port}
    ${re}    cli    eutA    show interface lag la1 configuration min-port
    should contain    ${re}    ${min_port}


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown

    