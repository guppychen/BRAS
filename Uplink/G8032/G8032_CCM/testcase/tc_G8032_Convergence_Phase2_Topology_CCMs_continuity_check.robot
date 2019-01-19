*** Settings ***
Documentation     Checking G8032 with CFM when continuity-check is enabled(by default) ring will be converged and ring goes to protection mode when continuity-check is disabled
...               1.Check g8032 ring with ccm cc enable
...               2.Check g8032 ring with ccm cc disable
...

Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_G8032_Convergence_Phase2_Topology_CCMs_continuity_check.robot
    [Tags]       @tcid=AXOS_E72_PARENT-TC-2045     @globalid=2329437    @eut=NGPON2-4    @feature=G8032    @subfeature=G8032    @author=pzhang
    [Documentation]    Checking G8032 with CFM when continuity-check is enabled(by default) ring will be converged and ring goes to protection mode when continuity-check is disabled
    ...               1.Check g8032 ring with ccm cc enable
    ...               2.Check g8032 ring with ccm cc disable
    [Setup]      setup
    log     check g8032 status and should be no alarm
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     Check g8032 ring with ccm cc disable

    prov_meg           eutA    ${meg1}    ${mep1}     continuity-check=disable
    prov_meg           eutA    ${meg2}    ${mep2}     continuity-check=disable
    prov_meg           eutB    ${meg3}    ${mep3}     continuity-check=disable
    prov_meg           eutB    ${meg4}    ${mep4}     continuity-check=disable

    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutA    ${service_model.service_point1.name}
    wait until keyword succeeds    2 min    10 s    check_g8032_ring_up    eutB    ${service_model.service_point2.name}

    log     success

    [Teardown]   teardown


*** Keywords ***
setup
    log     change wait-to-restore-time=1
    prov_g8032_ring     eutA     ${service_model.service_point1.name}    wait-to-restore-time=1
    prov_g8032_ring     eutB     ${service_model.service_point2.name}    wait-to-restore-time=1

    log     setup megs and chenge MEG level

    prov_meg           eutA    ${meg1}    ${mep1}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg1}    remote-mep=${mep3}
    prov_meg           eutA    ${meg1}    level=1
    prov_meg           eutA    ${meg2}    ${mep2}     direction=down     continuity-check=enable
    prov_meg           eutA    ${meg2}    remote-mep=${mep4}
    prov_meg           eutA    ${meg2}    level=1
    prov_meg           eutB    ${meg3}    ${mep3}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg3}    remote-mep=${mep1}
    prov_meg           eutB    ${meg3}    level=1
    prov_meg           eutB    ${meg4}    ${mep4}     direction=down     continuity-check=enable
    prov_meg           eutB    ${meg4}    remote-mep=${mep2}
    prov_meg           eutB    ${meg4}    level=1

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
