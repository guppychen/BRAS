*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_show_erps_ring_x_status_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x status both on master and transit node	Execute command successfully
    ...    2	Check parameters list and values	Correct
    ...    3	Shutdown primary or secondary port then check erps-ring status again	parameter values change correctly
    ...    4	no shutdown primary or secondary port then check erps-ring status again	parameter values change correctly
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1258    @globalid=2319008    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:1 Show erps-ring x status both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list and values Correct
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    check_erps_ring_status    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    configured-role=${service_model.${erps_node}.attribute.erps_role}
    \    ...   acting-role=${service_model.${erps_node}.attribute.erps_role}    primary-interface-fwd-state=forwarding

    log    STEP:3 Shutdown primary or secondary port then check erps-ring status again parameter values change correctly
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    check_erps_ring_status    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    configured-role=${service_model.${erps_node}.attribute.erps_role}
    \    ...   acting-role=${service_model.${erps_node}.attribute.erps_role}    primary-interface-fwd-state=blocking

    log    STEP:4 no shutdown primary or secondary port then check erps-ring status again parameter values change correctly
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    log    wait 20s for ring state change
    sleep    20s
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${control_vlan}    convert to string    ${service_model.${erps_node}.attribute.control_vlan}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_status    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    configured-role=${service_model.${erps_node}.attribute.erps_role}
    \    ...   acting-role=${service_model.${erps_node}.attribute.erps_role}
    \    ...    admin-state=enable    configured-role=${service_model.${erps_node}.attribute.erps_role}    control-vlan=${control_vlan}
    \    ...    primary-interface=${service_model.${erps_node}.member.interface1}    primary-interface-fwd-state=forwarding
    \    ...    secondary-interface=${service_model.${erps_node}.member.interface2}
 

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



