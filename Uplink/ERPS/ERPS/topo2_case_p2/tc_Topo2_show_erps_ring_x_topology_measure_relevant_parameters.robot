*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_Topo2_show_erps_ring_x_topology_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x topology both on master and transit node	Execute command successfully
    ...    2	Check parameters list	Should contain hostname, bridge-mac, serial-number, acting-role of all ring nodes
    [Tags]        @tcid=AXOS_E72_PARENT-TC-1260    @globalid=2319010    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4     @eut=GPON8-R2    dual_card_not_support
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x topology both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list Should contain hostname, bridge-mac, serial-number, acting-role of all ring nodes
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${res}    cli    ${service_model.${erps_node}.device}    show erps-ring ${service_model.${erps_node}.name} topology ring-node 1
    \    should contain    ${res}    ${service_model.${erps_node}.attribute.erps_role}
    \    ${mac}    get_baseboard_mac    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${mac}
    \    ${serial_num}    get_chassis_serial_number    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${serial_num}
    \    ${hostname}    get_hostname    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${hostname}

    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    ${res}    cli    ${service_model.${erps_node}.device}    show erps-ring ${service_model.${erps_node}.name} topology ring-node 1
    \    should contain    ${res}    ${service_model.${erps_node}.attribute.erps_role}
    \    ${mac}    get_baseboard_mac    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${mac}
    \    ${serial_num}    get_chassis_serial_number    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${serial_num}
    \    ${hostname}    get_hostname    ${service_model.${erps_node}.device}
    \    should contain    ${res}    ${hostname}

*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log     setup
    service_point_prov    service_point_list1
    service_point_prov    service_point_list2

    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1
    service_point_list_check_status_up    service_point_list2

teardown
    [Documentation]
    [Arguments]
    log     teardown
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2