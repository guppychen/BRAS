*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_MAC_learning_must_be_enabled_before_one2one_VLAN_add_to_ERPS_ring_ports
    [Documentation]    1.add one2one VLAN to ERPS ring port with mac learning disabled
    ...    add one2one VLAN to ERPS ring port with mac learning enabled
    [Tags]    @globalid=2318775    @tcid=AXOS_E72_PARENT-TC-1130    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step1.add one2one VLAN to ERPS ring port with mac learning disabled
    prov_vlan    eutA    ${service_vlan}    mac-learning=DISABLED
    ${res}    Run Keyword And Ignore Error    prov_erps_ring_on_interface    eutA    ${service_model.service_point1.member.interface1}    ${erps_ring}    none
    should contain    ${res[1]}    failed to apply modifications
    log    step2.add one2one VLAN to ERPS ring port with mac learning enabled
    prov_vlan    eutA    ${service_vlan}    mac-learning=ENABLED
    prov_erps_ring_on_interface    eutA    ${service_model.service_point1.member.interface1}    ${erps_ring}    none
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}
    prov_erps_ring    eutA    ${erps_ring}    transit    10

teardown
    [Documentation]    teardown
    log    teardown
    dprov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    erps-ring
    dprov_erps_ring    eutA    ${erps_ring}
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
