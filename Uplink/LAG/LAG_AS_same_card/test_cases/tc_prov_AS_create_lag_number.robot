*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_AS_lag_number
    [Documentation]    prov as lag number
    [Tags]    @globalid=2439407    @tcid=AXOS_E72_PARENT-TC-2989    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}
    lag_prov    eutA    ${la4}    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}

    ${re}    configure    eutA    inter la ${la3}
    ${re}    configure    eutA    inter la ${la2}
    ${re}    configure    eutA    inter la ${la1}
    ${re}    cli    eutA    show run inter la
    should contain    ${re}    ${la1}
    should contain    ${re}    ${la2}
    should contain    ${re}    ${la3}
    should contain    ${re}    ${la4}
    
    # ${re}    configure    eutA    no inter la ${la3}
    # ${re}    configure    eutA    no inter la ${la4}
    ${re}    configure    eutA    no inter la ${la3}
    ${re}    configure    eutA    no inter la ${la4}


    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown