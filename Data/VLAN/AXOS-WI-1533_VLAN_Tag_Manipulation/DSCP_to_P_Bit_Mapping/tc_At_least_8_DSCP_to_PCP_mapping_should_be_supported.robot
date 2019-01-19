*** Settings ***
Documentation     Check the maxmium numbers of DSCP map supported on DUT.
Resource          ./base.robot


*** Variables ***

${dscp_value3}    18
${dscp_value4}    20
${dscp_value5}    22
${dscp_value6}    26
${dscp_value7}    28
${dscp_value8}    30

${p_value3}    3
${p_value4}    4
${p_value5}    5
${p_value6}    6
${p_value7}    7
${p_value8}    0

*** Test Cases ***
tc_At_least_8_DSCP_to_PCP_mapping_should_be_supported
    [Documentation]    Check the maxmium numbers of DSCP map supported on DUT.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1241    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318903    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1241 setup
    [Teardown]   AXOS_E72_PARENT-TC-1241 teardown
    log    STEP:Check the maxmium numbers of DSCP map supported on DUT.

	log    CLI "show dscp-map"
	log    All of 8 dscp-maps show the DSCP to PCP mapping items correctly.
    : FOR   ${index}   IN RANGE    1    9
    \    verify_dscp_mapping     eutA    ${dscp_map${index}}    ${dscp_value${index}}    ${p_value${index}}


*** Keywords ***
AXOS_E72_PARENT-TC-1241 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1241 setup
    log    	Configure 8 dscp-map in CLI.
    : FOR   ${index}   IN RANGE    1    9
    \    prov_dscp_map    eutA    ${dscp_map${index}}    ${dscp_value${index}}     ${p_value${index}}

AXOS_E72_PARENT-TC-1241 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1241 teardown

    : FOR   ${index}   IN RANGE    1    9
    \    dprov_dscp_map    eutA    ${dscp_map${index}}
#    =======fix by chloe at ticket AT-1612
    ${type}    set variable    ${service_model.subscriber_point1.type}
    ${port_type1}    set variable if    'ont_port'=='${type}'    ont-ethernet
    set test variable    ${port_type}    ${port_type1}
    dprov_interface    eutA    ${port_type}     ${service_model.subscriber_point1.name}    role=${EMPTY}
