*** Settings ***
Documentation     The purpose of this test is to verify the scenario where a ring is established with CFM and then the MEG level is changed.
...               1.Check g8032 ring with ccm manual
...               2.change mep level and check g8032 status
...

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Topology_Negative_Scenario_ring_is_established_with_CFM_Manual_MEG_Level_Mismatch.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2024     @globalid=2329415    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]     The purpose of this test is to verify the scenario where a ring is established with CFM and then the MEG level is changed.
    ...               1.Check g8032 ring with ccm manual
    ...               2.change mep level and check g8032 status
    [Setup]      setup
    log     change wait-to-restore-time=1
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    wait-to-restore-time=1

    log     check g8032 alarm setting
    check_g8032_ring    eutA     ${service_model.service_point1.name}    status port-0-status      status="cfm-fail|fault|blocked"
    check_g8032_ring    eutA     ${service_model.service_point1.name}    status port-1-status      status="cfm-fail|fault|blocked"
    check_g8032_ring    eutB     ${service_model.service_point2.name}    status port-0-status      status="cfm-fail|fault|blocked"
    check_g8032_ring    eutB     ${service_model.service_point2.name}    status port-1-status      status="cfm-fail|fault|blocked"

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     setup megs and chenge MEG level

    prov_meg           eutA    ${meg1}    ${mep1}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg1}    remote-mep=${mep3}
    prov_meg           eutA    ${meg1}    level=5
    prov_meg           eutA    ${meg2}    ${mep2}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg2}    remote-mep=${mep4}
    prov_meg           eutA    ${meg2}    level=5
    prov_meg           eutB    ${meg3}    ${mep3}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg3}    remote-mep=${mep1}
    prov_meg           eutB    ${meg4}    ${mep4}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg4}    remote-mep=${mep2}

    log      assign megs to ethernet ports
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg1}    ${mep1}
    prov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}     ${service_model.service_point1.name}     ${EMPTY}    mep     ${meg2}    ${mep2}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg3}    ${mep3}
    prov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}     ${service_model.service_point2.name}     ${EMPTY}    mep     ${meg4}    ${mep4}


teardown
    log      unassign megs to ethernet ports
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface1}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutA    ${service_model.service_point1.member.interface2}      g8032_ring=${service_model.service_point1.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface1}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}
    dprov_interface_ethernet_g8032    eutB    ${service_model.service_point2.member.interface2}      g8032_ring=${service_model.service_point2.name}     ccm-protection=${EMPTY}

    log     remove ccm and then check g8032 status again
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log      delete megs
    delete_config_object    eutA    meg    ${meg1}
    delete_config_object    eutA    meg    ${meg2}
    delete_config_object    eutB    meg    ${meg3}
    delete_config_object    eutB    meg    ${meg4}
