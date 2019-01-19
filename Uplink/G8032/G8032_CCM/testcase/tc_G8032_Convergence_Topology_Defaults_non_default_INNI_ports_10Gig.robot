*** Settings ***
Documentation     The purpose of this test is to verify CFM autodiscovery works on 10 Gig INNI ports (other than the default discovery manager supported ports).
...               1.Config G8032 ring(10G)
...               2.config CCM auto to G8032 ring interface.
...               3.Check G8032 ring state(idle) and meg status
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_G8032_Convergence_Topology_Defaults_non_default_INNI_ports_10Gig.robot
    [Tags]    @tcid=AXOS_E72_PARENT-TC-2028    @globalid=2329420    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]      The purpose of this test is to verify CFM autodiscovery works on 10 Gig INNI ports (other than the default discovery manager supported ports).
    ...               1.Config G8032 ring(10G)
    ...               2.config CCM auto to G8032 ring interface.
    ...               3.Check G8032 ring state(idle) and meg status
    [Setup]    setup
    log    change wait-to-restore-time=1
    prov_g8032_ring    eutA    ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring    eutB    ${service_model.service_point2.name}    wait-to-restore-time=1
    log    check (10G)g8032 status
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}
    log    No meg configure
    check_meg    eutA    ${EMPTY}    ${EMPTY}    No entries
    log    success
    [Teardown]    teardown

*** Keywords ***
setup
    log    change wait-to-restore-time=1
    prov_g8032_ring    eutA    ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring    eutB    ${service_model.service_point2.name}    wait-to-restore-time=1
    prov_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point1.name}    ccm-protection=auto
    prov_interface    eutA    ethernet    ${service_model.service_point1.member.interface2}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point1.name}    ccm-protection=auto
    prov_interface    eutB    ethernet    ${service_model.service_point2.member.interface1}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point2.name}    ccm-protection=auto
    prov_interface    eutB    ethernet    ${service_model.service_point2.member.interface2}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point2.name}    ccm-protection=auto

teardown
    dprov_interface    eutA    ethernet    ${service_model.service_point1.member.interface1}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point1.name}    ccm-protection=auto
    dprov_interface    eutA    ethernet    ${service_model.service_point1.member.interface2}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point1.name}    ccm-protection=auto
    dprov_interface    eutB    ethernet    ${service_model.service_point2.member.interface1}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point2.name}    ccm-protection=auto
    dprov_interface    eutB    ethernet    ${service_model.service_point2.member.interface2}    sub_view_type=g8032-ring    sub_view_value=${service_model.service_point2.name}    ccm-protection=auto
