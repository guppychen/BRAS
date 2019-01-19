*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_Topo2_change_erps_control_vlan_check_topology
    [Documentation]    1	Show erps-ring x topology both on master and transit node	Execute command successfully
    ...    2	check topology of erps ring	parameters is correct
    ...    3	Modify control-vlan of one node then check erps-ring topology again	parameter values change correctly
    ...    4	recover control-vlan then check erps-ring topology again	parameter values change correctly
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2736    @globalid=2373828    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4     @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x topology both on master and transit node Execute command successfully
    log    STEP:2 check topology of erps ring parameters is correct

    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface1}
    should be equal    ${neiport_state}    forwarding

    ${neiname_1}    ${neiport_1}    ${neiport_state_1}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point3.device}     ${service_model.service_point3.name}     ${service_model.service_point3.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point4.device}
    should be equal    ${neiname_1}    ${hostname}
    should be equal    ${neiport_1}    ${service_model.service_point4.member.interface1}
    should be equal    ${neiport_state_1}    forwarding

    log    STEP:3 Modify control-vlan of one node then check erps-ring topology again parameter values change correctly
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan_1}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutC    2
    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface1}
    should be equal    ${neiport_state}    forwarding

    ${neiname_1}    ${neiport_1}    ${neiport_state_1}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point3.device}     ${service_model.service_point3.name}     ${service_model.service_point3.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point4.device}
    should be equal    ${neiname_1}    ${hostname}
    should be equal    ${neiport_1}    ${service_model.service_point4.member.interface1}
    should be equal    ${neiport_state_1}    forwarding

    log    STEP:4 recover control-vlan then check erps-ring topology again parameter values change correctly
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${service_model.${erps_node}.attribute.control_vlan}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${service_model.${erps_node}.attribute.control_vlan}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutC    2 
    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface1}
    should be equal    ${neiport_state}    forwarding

    ${neiname_1}    ${neiport_1}    ${neiport_state_1}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point3.device}     ${service_model.service_point3.name}     ${service_model.service_point3.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point4.device}
    should be equal    ${neiname_1}    ${hostname}
    should be equal    ${neiport_1}    ${service_model.service_point4.member.interface1}
    should be equal    ${neiport_state_1}    forwarding


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
