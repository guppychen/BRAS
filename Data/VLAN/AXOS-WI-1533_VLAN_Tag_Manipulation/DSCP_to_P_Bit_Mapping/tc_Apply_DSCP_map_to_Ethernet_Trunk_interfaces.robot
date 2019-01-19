*** Settings ***
Documentation     DSCP maps exist on DUT. The role of Ethernet interface set to INNI.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Apply_DSCP_map_to_Ethernet_Trunk_interfaces
    [Documentation]    DSCP maps exist on DUT. The role of Ethernet interface set to INNI.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1243    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318905    @eut=NGPON2-4    @priority=P1        @ticket=EXA-18797
    [Setup]      AXOS_E72_PARENT-TC-1243 setup
    [Teardown]   AXOS_E72_PARENT-TC-1243 teardown
    log    STEP:DSCP maps exist on DUT. The role of Ethernet interface set to INNI.

    ${type}    set variable    ${service_model.service_point1.type}
    ${port_type1}    set variable if    'eth' == '${type}'    ethernet
    set test variable    ${port_type}     ${port_type1}

    log    Apply DSCP map to INNI Ethernet interface.
    prov_interface     eutA    ${port_type}    ${service_model.service_point1.member.interface1}     role=inni    dscp-map=${dscp_map1}
    check_running_configure     eutA    interface      ${port_type}     ${service_model.service_point1.member.interface1}     dscp-map     dscp-map=${dscp_map1}
    log    Apply another DSCP map to the INNI Ethernet interface.
    comment    [EXA-18797] NGPON2-4: CLI - The new configuration can't override the old in DSCP mapping.
    prov_interface     eutA    ${port_type}    ${service_model.service_point1.member.interface1}     dscp-map=${dscp_map2}
    log    The new one will override the old one.
    check_running_configure     eutA    interface      ${port_type}     ${service_model.service_point1.member.interface1}     dscp-map     dscp-map=${dscp_map2}


*** Keywords ***
AXOS_E72_PARENT-TC-1243 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1243 setup
    prov_dscp_map    eutA    ${dscp_map1}    ${dscp_value1}     ${p_value1}
    prov_dscp_map    eutA    ${dscp_map2}    ${dscp_value2}     ${p_value2}

AXOS_E72_PARENT-TC-1243 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1243 teardown
    log    Remove DSCP map from INNI Ethernet interface.
    dprov_interface    eutA    ${port_type}     ${service_model.service_point1.member.interface1}    dscp-map=${EMPTY}

    dprov_dscp_map    eutA    ${dscp_map1}
    dprov_dscp_map    eutA    ${dscp_map2}


