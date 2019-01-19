*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm VLAN IF deletion works.
*** Variables ***

*** Test Cases ***
tc_delete_vlan_if
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision vlan, add IP address (VLAN IF), then delete the VLAN IF, confirm the deletion works.		
    [Tags]   dual_card_not_support     @author=ywu     @TCID=AXOS_E72_PARENT-TC-1007    @globalid=2316469    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1007 setup
    [Teardown]   AXOS_E72_PARENT-TC-1007 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision vlan, add IP address (VLAN IF), then delete the VLAN IF, confirm the deletion works.

    log    provision l3 vlan
    Prov_l3_vlan_l3_enable    eutA    ${l3_vlan_name}
    Prov_l3_vlan_ip    eutA     ${l3_vlan_name}    ${ipv4_address}    ${ipv4_mask}

    log    check l3 vlan
    ${result}    cli    eutA    show run interface vlan ${l3_vlan_name}
    should contain    ${result}    ${ipv4_address}

    log    remove vlan
    deprov_l3_vlan    eutA    ${l3_vlan_name}

    log    check l3 vlan
    ${result}    cli    eutA    show run interface vlan ${l3_vlan_name}
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:


*** Keyword ***
AXOS_E72_PARENT-TC-1007 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1007 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove vlan
    deprov_l3_vlan    eutA    ${l3_vlan_name}


