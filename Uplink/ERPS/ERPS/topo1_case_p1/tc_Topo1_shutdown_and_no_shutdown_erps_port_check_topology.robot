*** Settings ***
Documentation     Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_Topo1_shutdown_and_no_shutdown_erps_port_check_topology
    [Documentation]    1	Show erps-ring x topology both on master and transit node	Execute command successfully
    ...    2	check topology of erps ring	parameters is correct
    ...    3	Shutdown primary or secondary port then check erps-ring topology again	parameter values change correctly
    ...    4	no shutdown primary or secondary port then check erps-ring topology again	parameter values change correctly
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2438    @globalid=2359802    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
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

    log    STEP:3 Shutdown primary or secondary port then check erps-ring topology again parameter values change correctly
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    ${neiname_1}    ${neiport_1}    ${neiport_state_1}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname_1}    ${hostname}
    should be equal    ${neiport_1}    ${service_model.service_point2.member.interface2}
    should be equal    ${neiport_state_1}    blocking

    log    STEP:4 no shutdown primary or secondary port then check erps-ring topology again parameter values change correctly
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_status    ${service_model.service_point1.device}    ${service_model.service_point1.name}    primary-interface-fwd-state=forwarding
    ${neiname_1}    ${neiport_1}    ${neiport_state_1}    Get_erps_neighbor_hostname_port
    ...    ${service_model.service_point1.device}     ${service_model.service_point1.name}     ${service_model.service_point1.member.interface1}
    ${hostname}    get_hostname    ${service_model.service_point2.device}
    should be equal    ${neiname_1}    ${hostname}
    should be equal    ${neiport_1}    ${service_model.service_point2.member.interface2}
    should be equal    ${neiport_state_1}    forwarding


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