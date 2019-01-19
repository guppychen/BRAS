*** Settings ***
Resource          ./base.robot

*** Variables ***


*** Test Cases ***
tc_prov_AS_lag_two_cards
    [Documentation]    prov as lag two cards
    [Tags]    @globalid=2439414    @tcid=AXOS_E72_PARENT-TC-2996    @subfeature=LAG_Active_Standby_Same_Card    @priority=P1    @eut=NGPON2-4
    [Setup]    case setup
    log    ${service_model.service_point1}
    lag_prov    eutA    ${la1}    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    lag_prov    eutB    ${la1}    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    ${re}    lag_inter_prov    eutA    ${service_model.service_point1.member.interface1}    ${la1}
    ${re}    lag_inter_prov    eutB    ${service_model.service_point2.member.interface1}    ${la1}
    ${re}    cli    eutA    show inter la ${la1} mem
    should contain    ${re}    ${service_model.service_point1.member.interface1}
    should contain    ${re}    ${eth_port_status}
    
    ${re}    cli    eutB    show inter la ${la1} mem
    should contain    ${re}    ${service_model.service_point2.member.interface1}
    should contain    ${re}    ${eth_port_status}



    [Teardown]    case teardown

*** Keywords ***
case setup
    log    Enter case setup

case teardown
    log    Enter case teardown

lag_prov
    [Arguments]    ${eut}    ${lag_no}    ${lacp_mode}    ${max_port}    ${min_port}    ${hash_mode}='src-dst-ip'
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter la ${lag_no}
    cli    ${eut}    switchport enable
    cli    ${eut}    lacp-mode ${lacp_mode}
    cli    ${eut}    hash-method ${hash_mode}
    cli    ${eut}    max-port ${max_port}
    cli    ${eut}    min-port ${min_port}
    cli    ${eut}    no shut
    cli    ${eut}    end

lag_inter_prov
    [Arguments]    ${eut}    ${eth_port_1}    ${lag_no}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter eth ${eth_port_1}
    cli    ${eut}    no shut
    cli    ${eut}    role lag
    cli    ${eut}    group ${lag_no}
    cli    ${eut}    end
    
lag_inter_unprov
    [Arguments]    ${eut}    ${eth_port_1}    ${lag_no}
    [Tags]    @author=Sewang
    cli    ${eut}    config
    cli    ${eut}    inter eth ${eth_port_1}
    cli    ${eut}    shut
    cli    ${eut}    no group
    cli    ${eut}    no role
    cli    ${eut}    end