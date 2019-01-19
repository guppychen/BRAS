*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_show_erps_ring_x_history_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x history both on master and transit node	Execute command successfully
    ...    2	Check history list	Should contain domain id, sequence number, protocol state and state chenge time
    ...    3	Shutdown/no shutdown primary or secondary port	Execute command successfully
    ...    4	Show erps-ring x history and check history list again	Should produce some new history
    [Tags]        @tcid=AXOS_E72_PARENT-TC-1256    @globalid=2319006    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x history both on master and transit node Execute command successfully
    log    STEP:2 Check history list Should contain domain id, sequence number, protocol state and state change time

    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    ${time}    get_erps_last_topo_change_time    eutA    6
    ${res}    cli    eutA    show erps-ring 6 history
    ${result}    Get Regexp Matches    ${res}     \\d+\\s+(\\S+)\\s+${time}    1
    ${state}    set variable    ${result[0]}
    should be equal    ${state}    complete
    should contain    ${res}    domain-id 6
    should contain    ${res}    idle

    log    STEP:3 Shutdown/no shutdown primary or secondary port Execute command successfully
    shutdown_port    eutC    ethernet    ${service_model.service_point2.member.interface1}
    log    sleep 20s to wait erps ring protocol state change
    sleep    20s
    ${state}    get_erps_last_protocol_state    eutA    6
    should be equal    ${state}    port-down


    log    STEP:4 Show erps-ring x history and check history list again Should produce some new history
    no_shutdown_port    eutC    ethernet    ${service_model.service_point2.member.interface1}
    log    sleep 20s to wait erps ring protocol state change
    sleep    20s
    ${state}    get_erps_last_protocol_state    eutA    6
    should be equal    ${state}    complete

*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log     setup
    service_point_prov    service_point_list1

    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1



teardown
    [Documentation]
    [Arguments]
    log     teardown
    service_point_dprov    service_point_list1


