*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_create_a_VLAN_and_set_the_vlan_mode_as_one2one
    [Documentation]    1.create a VLAN and set the vlan mode as one2one
    [Tags]    @globalid=2318771    @tcid=AXOS_E72_PARENT-TC-1126    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    check_running_configure_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: create a VLAN ${service_vlan} and set the vlan mode as one2one
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE

teardown
    [Documentation]    teardown
    log    teardown
    delete_config_object    eutA    vlan    ${service_vlan}
