*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_prov_AS_create_lag1
    [Documentation]    prov create lag1
    [Tags]    @globalid=2439403    @tcid=AXOS_E72_PARENT-TC-2985    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}

#    ${re}    cli    eutA    show inter la la1 status
#    ${speed}    ${admin_status}    should Match Regexp    ${re}    admin-state\\s+(\\w+)
#    ${speed}    ${oper_status}    should Match Regexp    ${re}    oper-state\\s+(\\w+)
#    should contain    ${admin_status}    ${admin_state}
#    should contain    ${oper_status}    ${opr_state}
    wait until keyword succeeds    20 min     2 sec    check_lag_interface_status      eutA     ${la1}    ${admin_state}    ${opr_state}



    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup
    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    lag_prov    eutA    la2    ${lag_mode_passive}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}

case teardown
    log    Enter case teardown


    