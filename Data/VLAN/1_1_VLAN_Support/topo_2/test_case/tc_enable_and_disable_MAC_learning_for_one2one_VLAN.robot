*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_enable_and_disable_MAC_learning_for_one2one_VLAN
    [Documentation]    1.enable and disable MAC learning for one2one VLAN
    [Tags]    @globalid=2318774    @tcid=AXOS_E72_PARENT-TC-1129    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step1.enable and disable MAC learning for one2one VLAN
    prov_vlan    eutA    ${service_vlan}    mac-learning=DISABLED
    prov_vlan    eutA    ${service_vlan}    mac-learning=ENABLED
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}

teardown
    [Documentation]    teardown
    log    teardown
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
