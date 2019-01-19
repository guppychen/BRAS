*** Settings ***
Documentation     The purpose of this test case is to verify CCM is no longer sent when the CFM G8032 is configured for "Auto" and then removed.
...               1.Config G8032 ring.
...               2.config CCM to G8032 ring interface.
...               3.remove ccm auto and Check G8032 ring state(idle).

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Topology_Default_CFM_Disable.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2004     @globalid=2329393    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]     The purpose of this test case is to verify CCM is no longer sent when the CFM G8032 is configured for "Auto" and then removed.
    ...               1.Config G8032 ring.
    ...               2.config CCM to G8032 ring interface.
    ...               3.remove ccm auto and Check G8032 ring state(idle).
    [Setup]      setup

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

    log     remove ccm auto and Check G8032 ring state(idle).
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}





