*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_show_erps_ring_x_lccm_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x lccm both on master and transit node	Execute command successfully
    ...    2	Check parameters list	Should contain domain id, lccm-rx, lccm-tx, lccm-up-event, lccm-down-event, far-end-fail, adjacent-master-secondary-port and neighbor-port-mac of primary-interface and secondary-interface
    ...    3	Check parameter values	Correct
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1257    @globalid=2319007    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x lccm both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list Should contain domain id, lccm-rx, lccm-tx, lccm-up-event, lccm-down-event, far-end-fail, adjacent-master-secondary-port and neighbor-port-mac of primary-interface and secondary-interface
    log    STEP:3 Check parameter values Correct
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    primary-interface    lccm-rx    lccm-tx
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    secondary-interface    lccm-rx    lccm-tx


*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
    service_point_prov    service_point_list1



teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    deprovision erps ring on each node 
    service_point_dprov    service_point_list1
