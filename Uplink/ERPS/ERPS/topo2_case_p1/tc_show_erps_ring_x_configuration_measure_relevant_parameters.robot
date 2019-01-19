*** Settings ***
Documentation     Configure an ERPS ring with two nodes (Node1 and Node2 in Topo2)
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***


*** Test Cases ***
tc_show_erps_ring_x_configuration_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x configuration both on master and transit node	Execute command successfully
    ...    2	Check parameters list	Should contain domain id, admin-state, configured-role, control-vlan, health-time, recovery-time, topology-monitor, primary-interface and secondary-interface
    ...    3	Check parameter values	Correct
    ...    4	Modify all of these parameter values	Execute command successfully
    ...    5	Show erps-ring x configuration and check parameter values again	Show the modified values
    [Tags]       @globalid=2319004    @tcid=AXOS_E72_PARENT-TC-1254    @priority=P1   @eut=NGPON2-4    @subfeature=ERPS    @eut=GPON8-R2
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:1 Show erps-ring x configuration both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list Should contain domain id, admin-state, configured-role, control-vlan, health-time, recovery-time, topology-monitor, primary-interface and secondary-interface
    log    STEP:3 Check parameter values Correct
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${res}    AXOS CLI WITH ERROR CHECK    ${service_model.${erps_node}.device}    show erps-ring ${service_model.${erps_node}.name} configuration
    \    ${control_vlan}    convert to string    ${service_model.${erps_node}.attribute.control_vlan}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_configuration    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    domain-id=${domain_id}
    \    ...    admin-state=enable    configured-role=${service_model.${erps_node}.attribute.erps_role}    control-vlan=${control_vlan}
    \    ...    health-time=${health_time_default}    recovery-time=${recovery_time_default}    topology-monitor=enable    primary-interface=${service_model.${erps_node}.member.interface1}
    \    ...    secondary-interface=${service_model.${erps_node}.member.interface2}
   
    log    STEP:4 Modify all of these parameter values Execute command successfully
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    admin-state=disable    control-vlan=55    health-time=6    recovery-time=2
    \    ...    role=transit

    log    STEP:5 Show erps-ring x configuration and check parameter values again Show the modified values
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    ${res}    AXOS CLI WITH ERROR CHECK    ${service_model.${erps_node}.device}    show erps-ring ${service_model.${erps_node}.name} configuration
    \    ${control_vlan}    convert to string    ${service_model.${erps_node}.attribute.control_vlan}
    \    ${domain_id}    convert to string    ${service_model.${erps_node}.name}
    \    check_erps_ring_configuration    ${service_model.${erps_node}.device}    ${service_model.${erps_node}.name}    domain-id=${domain_id}
    \    ...    admin-state=disable    control-vlan=55    health-time=6    recovery-time=2


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
