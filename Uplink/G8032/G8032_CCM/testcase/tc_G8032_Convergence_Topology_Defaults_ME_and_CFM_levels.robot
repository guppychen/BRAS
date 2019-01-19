*** Settings ***
Documentation     G8032 ring  with CCM auto.The ring state should be idle.
...               1.Config G8032 ring.
...               2.config CCM to G8032 ring interface.
...               3.Check G8032 ring state(idle).

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Topology_Defaults_ME_and_CFM_levels.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1998     @globalid=2329385    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]     G8032 ring  with CCM auto.The ring state should be idle.
    ...               1.Config G8032 ring.
    ...               2.config CCM to G8032 ring interface.
    ...               3.Check G8032 ring state(idle).
    [Setup]      setup
    log     check g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     change wait-to-restore-time=1
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






