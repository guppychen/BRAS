*** Settings ***
Documentation     The purpose of this test is to see what happens when the ME level is modified to be a lower level than the CFM level atuo configured.
...               Check G8032 ME level and CFM ME level have no relationship.

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Topology_Negative_Auto_CFM_Lower_ME_Level_than_CFM.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2012     @globalid=2329403    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]     The purpose of this test is to see what happens when the ME level is modified to be a lower level than the CFM level atuo configured.
    ...               Check G8032 ME level and CFM ME level have no relationship.
    [Setup]      setup
    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     change G8032 ME to 0
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    maintenance-entity-level=0
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    maintenance-entity-level=0

    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     change g8032 ME to 3
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    maintenance-entity-level=3
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    maintenance-entity-level=3

    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     change g8032 ME to 7
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    maintenance-entity-level=7
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    maintenance-entity-level=7

    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     change wait-to-restore-time=1.
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    wait-to-restore-time=1

    prov_interface     eutA    ethernet    ${service_model.service_point1.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}       ccm-protection=auto
    prov_interface     eutA    ethernet    ${service_model.service_point1.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}       ccm-protection=auto
    prov_interface     eutB    ethernet    ${service_model.service_point2.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}       ccm-protection=auto
    prov_interface     eutB    ethernet    ${service_model.service_point2.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}       ccm-protection=auto

teardown
    dprov_interface     eutA    ethernet    ${service_model.service_point1.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}      ccm-protection=auto
    dprov_interface     eutA    ethernet    ${service_model.service_point1.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point1.name}      ccm-protection=auto
    dprov_interface     eutB    ethernet    ${service_model.service_point2.member.interface1}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}      ccm-protection=auto
    dprov_interface     eutB    ethernet    ${service_model.service_point2.member.interface2}     sub_view_type=g8032-ring     sub_view_value=${service_model.service_point2.name}      ccm-protection=auto





