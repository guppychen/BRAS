*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Change_VLAN_mode_to_one2one_when_uplink_is_in_membership
    [Documentation]    1.create a VLAN and add a uplink port to the vlan by transport-service-profile
    ...    2.change vlan mode to be one2one
    [Tags]    @globalid=2318772    @tcid=AXOS_E72_PARENT-TC-1127    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step2: change vlan mode to be one2one
    cli    eutA    configure
    ${res}    cli    eutA    VLAN ${service_vlan} mode ONE2ONE
    should contain any    ${res}    Cannot set VLAN mode    Failed to set mode
    cli    eutA    end
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: create a VLAN and add a uplink port to the vlan by transport-service-profile
    prov_vlan    eutA    ${service_vlan}    mode=N2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}

teardown
    [Documentation]    teardown
    log    teardown
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
