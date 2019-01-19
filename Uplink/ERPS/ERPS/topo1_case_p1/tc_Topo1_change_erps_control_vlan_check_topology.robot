*** Settings ***
Documentation     Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo1_change_erps_control_vlan_check_topology
    [Documentation]    1	Show erps-ring x topology both on master and transit node	Execute command successfully
    ...    2	check topology of erps ring	parameters is correct
    ...    3	Modify control-vlan of one node then check erps-ring topology again	parameter values change correctly
    ...    4	recover control-vlan then check erps-ring topology again	parameter values change correctly
    [Tags]        @tcid=AXOS_E72_PARENT-TC-2437    @globalid=2359801    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x topology both on master and transit node Execute command successfully
    log    STEP:2 check topology of erps ring parameters is correct
    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface2}
    should be equal    ${neiport_state}    forwarding

    log    STEP:3 Modify control-vlan of one node then check erps-ring topology again parameter values change correctly
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface2}
    should be equal    ${neiport_state}    forwarding

    log    STEP:4 recover control-vlan then check erps-ring topology again parameter values change correctly
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${service_model.${erps_node}.attribute.control_vlan}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6
    ${neiname}    ${neiport}    ${neiport_state}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname}    ${hostname}
    should be equal    ${neiport}    ${service_model.service_point2.member.interface2}
    should be equal    ${neiport_state}    forwarding


*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes
    service_point_prov    service_point_list1

teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
