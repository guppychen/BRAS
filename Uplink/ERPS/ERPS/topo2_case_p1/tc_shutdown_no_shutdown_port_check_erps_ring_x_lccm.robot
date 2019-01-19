*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_show_erps_ring_x_lccm_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x lccm both on master and transit node	Execute command successfully
    ...    2	Shutdown primary or secondary port then check erps-ring lccm again	parameter values change correctly
    ...    3	no shutdown primary or secondary port then check erps-ring lccm again	parameter values change correctly
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2713    @globalid=2362101    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x lccm both on master and transit node Execute command successfully
    log    STEP:2 Shutdown primary or secondary port then check erps-ring lccm again parameter values change correctly
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}  
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    check_erps_ring_lccm_not_change   ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   primary-interface    lccm-rx
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   primary-interface    lccm-tx
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   secondary-interface    lccm-rx
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   secondary-interface    lccm-tx

    
    
    log    STEP:3 no shutdown primary or secondary port then check erps-ring lccm again parameter values change correctly
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    primary-interface-fwd-state=forwarding
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   primary-interface    lccm-rx    lccm-tx
    \    check_erps_ring_lccm_increase    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}   secondary-interface    lccm-rx    lccm-tx
    


*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes
    service_point_prov    service_point_list1
    service_point_list_check_status_up    service_point_list1


teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
