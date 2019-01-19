*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
shutdown_no shutdown_port_check_erps_ring_x_counters 
    [Documentation]    1	Show erps-ring x counters both on master and transit node	Execute command successfully
    ...    2	Check parameters list and values	Correct
    ...    3	Shutdown/no shutdown primary or secondary port	Execute command successfully
    ...    4	Show erps-ring x counters and check parameter values again	Values of ring-up, ring-down, health-tx,hello-rx, etc, will increase
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1255    @globalid=2319005    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:1 Show erps-ring x counters both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list and values Correct
    wait until keyword succeeds    2 min    5 sec   check_erps_ring_up    ${service_model.service_point1.device}    ${service_model.service_point1.name}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${control_vlan}    convert to string    ${service_model.${erps_node}.attribute.control_vlan}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_counters   ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    domain-id=${domain_id}    ring-up=1

    log    STEP:3 Shutdown/no shutdown primary or secondary port Execute command successfully
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    2 min    5 sec   check_erps_ring_up    ${service_model.service_point1.device}    ${service_model.service_point1.name}

    log    STEP:4 Show erps-ring x counters and check parameter values again Values of ring-up, ring-down, health-tx,hello-rx, etc, will increase
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_counters   ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    domain-id=${domain_id}    ring-up=2


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

