*** Settings ***
Documentation     Check the default DSCP to PCP mapping table.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_The_system_default_DSCP_to_PCP_mapping
    [Documentation]    Check the default DSCP to PCP mapping table.
    [Tags]       @author=Wanlin Sun     @tcid=AXOS_E72_PARENT-TC-1239    @feature=VLAN    @subfeature=VLAN_Tag_Manipulation
    ...     @globalid=2318901    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-1239 setup
    [Teardown]   AXOS_E72_PARENT-TC-1239 teardown
    log    STEP:Check the default DSCP to PCP mapping table.

    log    CLI "show running-config dscp-map".
    log    Check the value of each DSCP to PCP.

    : FOR   ${index}   IN RANGE    1    23
    \    verify_dscp_mapping     eutA    UNI    ${dscp_default.p${index}.dscp_value}    ${dscp_default.p${index}.p_value}


*** Keywords ***
AXOS_E72_PARENT-TC-1239 setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1239 setup


AXOS_E72_PARENT-TC-1239 teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-1239 teardown

