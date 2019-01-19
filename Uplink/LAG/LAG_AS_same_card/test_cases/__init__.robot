*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @author=Sean Wang    @feature=LAG
Resource          ./base.robot

*** Variables ***

*** Keywords ***

provision
    [Arguments]
    [Tags]    @author=Sewang
    set eut version
    service_point_lag_prov    eutA    service_point1
    service_point_lag_prov    eutB    service_point2
    service_point_lag_prov    eutA    service_point3
    service_point_lag_prov    eutB    service_point4


    lag_prov    eutA    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    lag_prov    eutB    la1    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    lag_prov    eutA    la2    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}
    lag_prov    eutB    la2    ${lag_mode_active}    ${max_port}    ${min_port}    ${hash_mode_srcdstip}

    wait until keyword succeeds    1 min     5 sec    check_lag_interface_status      eutA     ${la1}    ${admin_state}    ${opr_state}

deprovision
    [Arguments]
    [Tags]    @author=Sewang
    service_point_lag_dprov    eutA    service_point1
    service_point_lag_dprov    eutB    service_point2
    service_point_lag_dprov    eutA    service_point3
    service_point_lag_dprov    eutB    service_point4