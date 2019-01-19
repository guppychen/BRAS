*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision VLAN IF works.
*** Variables ***

*** Test Cases ***
tc_provision_vlan_if
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision vlan, add IP address, confirm provision works (as VLAN-IF)		
    [Tags]    dual_card_not_support   @author=ywu     @TCID=AXOS_E72_PARENT-TC-1005    @globalid=2316467    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1005 setup
    [Teardown]   AXOS_E72_PARENT-TC-1005 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision vlan, add IP address, confirm provision works (as VLAN-IF)

    log    provision l3 vlan
    Prov_l3_vlan_l3_enable    eutA    ${l3_vlan_name}
    Prov_l3_vlan_ip    eutA     ${l3_vlan_name}    ${ipv4_address}    ${ipv4_mask}

    log    check l3 vlan
    ${result}    cli    eutA    show run interface vlan ${l3_vlan_name}
    should contain    ${result}    ${ipv4_address}




*** Keyword ***
AXOS_E72_PARENT-TC-1005 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1005 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove vlan
    deprov_l3_vlan    eutA    ${l3_vlan_name}


