*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_clear_erps_ring_counters_check_erps_ring_x_counters
    [Documentation]    1	Show erps-ring x counters both on master and transit node	Execute command successfully
    ...    2	Check parameters list and values	Correct
    ...    3	Clear erps-ring x counters	Execute command successfully
    ...    4	Show erps-ring x counters and check parameters values	Values of health-rx, hello-rx,health-tx and hello-tx will be cleared and increase continually; other counters will keep as 0
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2714    @globalid=2362555    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4     @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x counters both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list and values Correct
     
    cli     eutA    clear erps-ring ${service_model.service_point1.name} counters
    wait until keyword succeeds    2 min    5 sec   check_erps_ring_up    ${service_model.service_point1.device}    ${service_model.service_point1.name}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${control_vlan}    convert to string    ${service_model.${erps_node}.attribute.control_vlan}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_counters   ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    domain-id=${domain_id}

    log    STEP:3 Clear erps-ring x counters Execute command successfully
    AXOS CLI WITH ERROR CHECK     eutA    clear erps-ring ${service_model.service_point1.name} counters

    log    STEP:4 Show erps-ring x counters and check parameters Values of health-rx, hello-rx,health-tx and hello-tx will be cleared and increase continually; other counters will keep as 0
    check_erps_counters_equal_0    eutA    6    @{erps_counters}
    check_erps_counters_increase    eutA    6    @{erps_counters_increase}


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

