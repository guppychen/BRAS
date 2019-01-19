*** Settings ***
Documentation     Check the default value of DSCP to PCP mapping.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_default_value_of_DSCP_to_PCP_mapping
    [Documentation]    Check the default value of DSCP to PCP mapping.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1238    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318900    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1238 setup
    [Teardown]   AXOS_E72_PARENT-TC-1238 teardown
    log    STEP:Check the default value of DSCP to PCP mapping.

    log    CLI "show dscp-map"
    log    Check the value of each DSCP to PCP.

    : FOR   ${index}   IN RANGE    1    23
    \    verify_dscp_mapping     eutA    ${dscp_map1}    ${dscp_default.p${index}.dscp_value}    ${dscp_default.p${index}.p_value}

*** Keywords ***
AXOS_E72_PARENT-TC-1238 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1238 setup
    log    Create a DSCP-map.
    prov_dscp_map    eutA    ${dscp_map1}

AXOS_E72_PARENT-TC-1238 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1238 teardown

    dprov_dscp_map    eutA    ${dscp_map1}

