*** Settings ***
Documentation     Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_trigger_erps_acting_master_alarm_measure_history_stats_of_erps_ring_and_alarm_raising_and_clearing
    [Documentation]    1	Modify master node as transit role	Modify successfully
    ...    2	show alarm active	get erps-acting-master alarm raised time
    ...    3	show erps-domain, verify topology change time	the same as alarm time
    ...    4	Modify transit node back to master role	Modify successfully
    ...    5	show alarm active	alarm is cleared
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1319    @globalid=2319069    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2     @jira=AT-4998
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Modify master node as transit role Modify successfully
    prov_erps_ring    eutA    ${service_model.service_point1.name}    transit
    log    STEP:2 show alarm active get erps-acting-master alarm raised time
    # add by llin, in dual card the alarm will several seconds delay.
    ${time1}  wait until keyword succeeds  1min   3s  get_alarm_active_time    eutA    erps-acting-master
    ${time_1}    convert Date    ${time1}    epoch
    log    STEP:3 show erps-domain, verify topology change time the same as alarm time
    ${time2}   get_erps_last_topo_change_time     eutA    ${service_model.service_point1.name}
    ${time_2}    convert Date    ${time2}    epoch
    should be true    abs(${time_1}-${time_2})<5
    
    log    STEP:4 Modify transit node back to master role Modify successfully
    prov_erps_ring    eutA    ${service_model.service_point1.name}    master

    log    STEP:5 show alarm active alarm is cleared
    ${res}    cli    eutA    show alarm active
    should not contain    ${res}    erps-acting-master



*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes
    service_point_prov    service_point_list1


teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    deprovision erps ring on each node
    service_point_dprov    service_point_list1
