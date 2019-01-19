*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_trigger_erps_interface_down_and_erps_ring_down_alarm_measure_history_stats_of_erps_ring_and_alarm_raising_and_clearing
    [Documentation]    1	Shutdown interface on master node	ERPS Ring Port Down
    ...    2	show alarm active	get alarm erps-interface-down and erps-ring-down raised time
    ...    3	show erps-domain, verify topology change time	the same as alarm time
    ...    4	No shutdown interface on master node	ERPS Ring Port Up
    ...    5	show alarm active	alarm is cleared
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1302    @globalid=2319052    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Shutdown interface on master node ERPS Ring Port Down
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}

    log    STEP:2 show alarm active get alarm erps-interface-down and erps-ring-down raised time
    ${time1}    get_alarm_active_time    eutA    erps-interface-down
    ${time_1}    convert Date    ${time1}    epoch
    ${time2}    get_alarm_active_time    eutA    erps-ring-down

    log    STEP:3 show erps-domain, verify topology change time the same as alarm time
    ${time3}   get_erps_last_topo_change_time     eutA    ${service_model.service_point1.name}
    ${time_3}    convert Date    ${time3}    epoch
   should be true    abs(${time_1}-${time_3})<5

    log    STEP:4 No shutdown interface on master node ERPS Ring Port Up
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}

    log    STEP:5 show alarm active alarm is cleared
    log    sleep 20s to wait erps ring protocol state change
    sleep    20s
    ${res}    cli    eutA    show alarm active
    should not contain    ${res}    erps-interface-down
    should not contain    ${res}    erps-ring-down


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log     setup
    service_point_prov    service_point_list1



case teardown
    [Documentation]
    [Arguments]
    log     teardown
    service_point_dprov    service_point_list1
