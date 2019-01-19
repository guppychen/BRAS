*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_MAC_learning_must_be_enabled_before_one2one_VLAN_add_to_G8032_ring_ports
    [Documentation]    1.add one2one VLAN to G8032 ring port with mac learning disabled
    ...    add one2one VLAN to G8032 ring port with mac learning enabled
    [Tags]    @globalid=2318776    @tcid=AXOS_E72_PARENT-TC-1131    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step1.add one2one VLAN to G8032 ring port with mac learning disabled
    prov_vlan    eutA    ${service_vlan}    mac-learning=DISABLED
    Axos Cli With Error Check    eutA    configure
    Axos Cli With Error Check    eutA    interface ${service_model.service_point1.attribute.interface_type} ${service_model.service_point1.member.interface1}
    ${res}    Run Keyword And Ignore Error    cli    eutA    g8032-ring ${g8032_ring}
    should contain    ${res[1]}    failed to apply modifications
    Axos Cli With Error Check    eutA    end
    log    step2.add one2one VLAN to G8032 ring port with mac learning enabled
    prov_vlan    eutA    ${service_vlan}    mac-learning=ENABLED
    prov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    inni    g8032-ring=${g8032_ring}

    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}
    prov_g8032_ring    eutA    ${g8032_ring}    ${control_vlan}    enable

teardown
    [Documentation]    teardown
    log    teardown
    dprov_interface_ethernet    eutA    ${service_model.service_point1.member.interface1}    g8032-ring
    dprov_g8032_ring    eutA    ${g8032_ring}
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
