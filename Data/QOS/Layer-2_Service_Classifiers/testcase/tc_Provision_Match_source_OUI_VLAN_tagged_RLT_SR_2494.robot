*** Settings ***
Documentation     This test case is to confirm provision match source OUI (VLAN tagged) under class-map.
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Provision_Match_source_OUI_VLAN_tagged_RLT_SR_2494
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match source OUI (VLAN tagged), confirm provision complete.
    ...    2	Provision match source OUI with different OUI value, confirm provision complete.
    ...    3	Provision match source OUI with same OUI value, confirm provision is rejected.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-969    @globalid=2316427    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-969 setup
    [Teardown]   AXOS_E72_PARENT-TC-969 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes
    log    STEP:1 Provision match source OUI (VLAN tagged), confirm provision complete.

    log    STEP:2 Provision match source OUI with different OUI value, confirm provision complete.

    log    STEP:3 Provision match source OUI with same OUI value, confirm provision is rejected.


    log    STEP:1. match rules: src-mac;
    log    serivce 1
    log    configure class-map match vlan success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_match_vlan1}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_match_vlan1}
    log    ${class_map_result}
    log    configure class-map match src-mac success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    src-oui=${subscriber_oui1}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    src-oui=${subscriber_oui1}
    log    ${class_map_result}
    log    duplicate src-mac would be rejected
    ${result}    prov_class_map_without_error_check    eutA    ${class_map_name_check}    ethernet    flow     1    3    src-oui=${subscriber_oui1}
    should contain    ${result}    ${cli_error_msg_oui}





*** Keyword ***
AXOS_E72_PARENT-TC-969 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-969 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

