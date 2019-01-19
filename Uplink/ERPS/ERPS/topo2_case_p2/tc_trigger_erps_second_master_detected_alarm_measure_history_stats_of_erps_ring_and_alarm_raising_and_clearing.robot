*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_trigger_erps_second_master_detected_alarm_measure_history_stats_of_erps_ring_and_alarm_raising_and_clearing
    [Documentation]    1	Modify transit node as master role	ERPS Ring Port Down
    ...    2	show alarm active	get erps-second-master-detected alarm raised time
    ...    3	show erps-domain, verify topology change time	the same as alarm time
    ...    4	No shutdown interface on master node	ERPS Ring Port Up
    ...    5	show alarm active	alarm is cleared
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1304    @globalid=2319054    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Modify transit node as master role ERPS Ring Port Down
    prov_erps_ring    eutC    ${service_model.service_point2.name}    master

    log    STEP:2 show alarm active get erps-second-master-detected alarm raised time
    ${time1}    get_alarm_active_time    eutA    erps-second-master-detected
    ${time_1}    convert Date    ${time1}    epoch

    log    STEP:3 show erps-domain, verify topology change time the same as alarm time
    ${time2}   get_erps_last_topo_change_time     eutA    ${service_model.service_point1.name}
    ${time_2}    convert Date    ${time2}    epoch
    should be true    abs(${time_1}-${time_2})<5

    log    STEP:4 No shutdown interface on master node ERPS Ring Port Up
    prov_erps_ring    eutC    ${service_model.service_point2.name}    transit
    wait until keyword succeeds    2 min    5 sec   check_erps_ring_up    ${service_model.service_point1.device}    ${service_model.service_point1.name}

    log    STEP:5 show alarm active alarm is cleared
    ${res}    cli    eutC    show alarm active
    wait until keyword succeeds    2 min    5 sec    should not contain    ${res}    erps-second-master-detected

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    service_point_prov    service_point_list1
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1

case teardown
    [Documentation]
    [Arguments]
    service_point_dprov    service_point_list1
