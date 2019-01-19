*** Settings ***
Documentation     Configure an ERPS ring with three nodes
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo1_show_erps_ring_x_topology_measure_relevant_parameters
    [Documentation]    1	Show erps-ring x topology both on master and transit node	Execute command successfully
    ...    2	Check parameters list	Should contain hostname, bridge-mac, serial-number, acting-role of all ring nodes
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1259    @globalid=2319009    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2   dual_card_not_support
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 Show erps-ring x topology both on master and transit node Execute command successfully
    log    STEP:2 Check parameters list Should contain hostname, bridge-mac, serial-number, acting-role of all ring nodes and topology of this ring

    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
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
    log    Enter setup
    log    Configure an ERPS ring with three nodes
    service_point_prov    service_point_list1

teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
 