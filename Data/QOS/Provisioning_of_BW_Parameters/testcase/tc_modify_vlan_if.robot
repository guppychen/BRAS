*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm modify VLAN IF works.
*** Variables ***

*** Test Cases ***
tc_modify_vlan_if
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision vlan, add IP address (VLAN IF), then modify some parameter under the VLAN-IF, confirm the operation complete.		
    ...    2	Modify IP address. Modify IP address V4 --> V6, V6 --> V4 as well.		
    [Tags]   dual_card_not_support    @author=ywu     @TCID=AXOS_E72_PARENT-TC-1006    @globalid=2316468    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1006 setup
    [Teardown]   AXOS_E72_PARENT-TC-1006 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision vlan, add IP address (VLAN IF), then modify some parameter under the VLAN-IF, confirm the operation complete.

    log    STEP:2 Modify IP address. Modify IP address V4 --> V6, V6 --> V4 as well.

    log    provision l3 vlan ipv4 address
    Prov_l3_vlan_l3_enable    eutA    ${l3_vlan_name}
    Prov_l3_vlan_ip    eutA     ${l3_vlan_name}    ${ipv4_address}    ${ipv4_mask}

    log    check l3 vlan
    ${result}    cli    eutA    show run interface vlan ${l3_vlan_name}
    should contain    ${result}    ${ipv4_address}

    log    provision l3 vlan ipv6 address
    Prov_l3_vlan_l3_enable    eutA    ${l3_vlan_name}
    Prov_l3_vlan_ip    eutA     ${l3_vlan_name}    ${ipv6_address}    ${ipv6_mask}    v6

    log    check l3 vlan
    ${result}    cli    eutA    show run interface vlan ${l3_vlan_name}
    should contain    ${result}    ${ipv6_address}


*** Keyword ***
AXOS_E72_PARENT-TC-1006 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1006 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove vlan
    deprov_l3_vlan    eutA    ${l3_vlan_name}


