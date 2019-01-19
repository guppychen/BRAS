*** Settings ***
Documentation     1.Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_trigger_configuration_unresolved_alarm_alarm_measure_history_stats_of_erps_ring_and_alarm_raising_and_clearing
    [Documentation]    1	No control vlan	Modify successfully
    ...    2	show alarm active	get configuration-unresolved-alarm raised time
    ...    3	show erps-domain, verify topology change time	the same as alarm time
    ...    4	Modify control vlan back	Modify successfully
    ...    5	show alarm active	alarm is cleared
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1320    @globalid=2319070    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 No control vlan Modify successfully
    dprov_erps_ring    eutA    ${service_model.service_point1.name}    control-vlan 

    log    STEP:2 show alarm active get configuration-unresolved-alarm raised time
    ${time1}    get_alarm_active_time    eutA    erps-configuration-unresolved
    ${time_1}    convert Date    ${time1}    epoch
        
    log    STEP:3 show erps-domain, verify topology change time the same as alarm time
    ${time2}   get_erps_last_topo_change_time     eutA    ${service_model.service_point1.name}
    ${time_2}    convert Date    ${time2}    epoch
    should be true    abs(${time_1}-${time_2})<5
    
    log    STEP:4 Modify control vlan back Modify successfully
    prov_erps_ring    eutA    ${service_model.service_point1.name}    control-vlan=${service_model.service_point1.attribute.control_vlan} 
    
    log    STEP:5 show alarm active alarm is cleared
    ${res}    cli    eutA    show alarm active
    wait until keyword succeeds    2 min    5 sec     should not contain    ${res}    erps-configuration-unresolved



*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log     setup
    service_point_prov    service_point_list1
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1



case teardown
    [Documentation]
    [Arguments]
    log     teardown
    service_point_dprov    service_point_list1