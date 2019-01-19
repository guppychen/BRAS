*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_AS_create_hashmode
    [Documentation]    prov create hashmode
    [Tags]    @globalid=2439404    @tcid=AXOS_E72_PARENT-TC-2986    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_srcdstip}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_dstip}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_dstip}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_dstmac}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_dstmac}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstmac}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_srcdstmac}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcip}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_srcip}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcmac}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_srcmac}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstmacip}
    ${re}    cli    eutA    show inter la la1 status hash-method
    should contain    ${re}    ${hash_mode_srcdstmacip}
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}


    # ${re}    configure    eutA    no inter la ${la4}
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown
    