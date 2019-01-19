*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Change_VLAN_mode_to_N2one_when_uplink_is_in_membership
    [Documentation]    1.create a VLAN and set the vlan mode as one2one
    ...    2.add a uplink port to the vlan by transport-service-profile
    ...    3.change vlan mode to be N2one
    [Tags]    @globalid=2318773    @tcid=AXOS_E72_PARENT-TC-1128    @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step3: change vlan mode to be N2one
    cli    eutA    configure
    ${res}    cli    eutA    VLAN ${service_vlan} mode N2ONE
    should contain any    ${res}    Cannot set VLAN mode    Failed to set mode
    cli    eutA    end
    [Teardown]    teardown

*** Keywords ***
setup
    [Documentation]    setup
    clear_bridge_table    eutA
    log    step1: create a VLAN and set the vlan mode as one2one
    log    step2: add a uplink port to the vlan by transport-service-profile
    prov_vlan    eutA    ${service_vlan}    mode=ONE2ONE
    service_point_add_vlan    service_point_list1    ${service_vlan}

teardown
    [Documentation]    teardown
    log    teardown
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
