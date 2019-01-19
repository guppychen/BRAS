*** Settings ***
Documentation     Check the function of displaying for DSCP to PCP table entries. DSCP maps existing in DUT is required. Apply the DSCP maps to Ethernet interface and ONT-Ethernet interface.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Display_DSCP_to_PCP_mapping_rule
    [Documentation]    Check the function of displaying for DSCP to PCP table entries. DSCP maps existing in DUT is required. Apply the DSCP maps to Ethernet interface and ONT-Ethernet interface.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1240    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318902    @eut=NGPON2-4    @priority=P1              @ticket=EXA-19137
    [Setup]      AXOS_E72_PARENT-TC-1240 setup
    [Teardown]   AXOS_E72_PARENT-TC-1240 teardown
    log    STEP:Check the function of displaying for DSCP to PCP table entries. DSCP maps existing in DUT is required. Apply the DSCP maps to Ethernet interface and ONT-Ethernet interface.
    log    CLI "show dscp-map"

    ${names}    cli    eutA    show dscp-map displaylevel 1
    ${names}    Get Regexp Matches    ${names}    details\\s(\\w+)    1
    ${max}     Get Length     ${names}

    ${res}    cli    eutA    show dscp-map | nomore
    :FOR    ${index}    IN RANGE    0    ${max}
    \    ${name}    get from list    ${names}    ${index}
    \    set test variable    ${dscp_map_${index}}    ${name}
    \    Should Match Regexp    ${res}    Profile\\sName\\:\\s+${dscp_map_${index}}

    log    All of the dscp-map will be shown out, inclue details, references and summary.
    Should Match Regexp    ${res}    NAME\\s+INTERFACE\\s+ID\\s+ID
    Should Match Regexp    ${res}    NAME\\s+REFERENCES
    :FOR    ${index}    IN RANGE    0    ${max}
    \    Should Match Regexp    ${res}    Profile\\sName\\:\\s+${dscp_map_${index}}

    log    CLI "show dscp-map details"
    ${res}    cli    eutA    show dscp-map details
    log    All of the dscp to PCP mapping items will be shown out per dscp-map.
    verify_dscp_mapping     eutA    ${dscp_map1}    ${dscp_value1}    ${p_value1}
    : FOR   ${index}   IN RANGE    2    23
    \    verify_dscp_mapping     eutA    ${dscp_map1}    ${dscp_default.p${index}.dscp_value}    ${dscp_default.p${index}.p_value}

    log    CLI "show dscp-map references"
    comment    [EXA-19137] NGPON2-4: "show dscp-map references" overturns "show dscp-map summary"
    ${res}    cli    eutA    show dscp-map references
    log    All of the dscp-maps references will be shown out.
    ${id1}   ${id2}   ${id3}    Split String     ${service_model.service_point1.member.interface1}      /
    Should Match Regexp    ${res}    ${dscp_map1}\\s+${id3}\\s+${id1}\\s+${id2}

    log    CLI "show dscp-map summary"
    comment    [EXA-19137] NGPON2-4: "show dscp-map references" overturns "show dscp-map summary"
    ${res}    cli    eutA    show dscp-map summary
    log    All of the dscp-maps summary will be shown out.
    Should Match Regexp    ${res}    ${dscp_map1}\\s+1

*** Keywords ***
AXOS_E72_PARENT-TC-1240 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1240 setup

    prov_dscp_map    eutA    ${dscp_map1}    ${dscp_value1}     ${p_value1}
    ${type}    set variable    ${service_model.service_point1.type}
    ${port_type1}    set variable if    'eth' == '${type}'    ethernet
    set test variable    ${port_type}     ${port_type1}
    log    Apply DSCP map to UNI interface.
    prov_interface     eutA    ${port_type}    ${service_model.service_point1.member.interface1}     role=inni    dscp-map=${dscp_map1}


AXOS_E72_PARENT-TC-1240 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1240 teardown

    dprov_interface    eutA    ${port_type}     ${service_model.service_point1.member.interface1}    dscp-map=${EMPTY}
    dprov_dscp_map    eutA    ${dscp_map1}


