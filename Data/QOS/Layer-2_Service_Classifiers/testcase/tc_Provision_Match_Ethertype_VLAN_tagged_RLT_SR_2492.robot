*** Settings ***
Documentation     This test case is to confirm provision match rule match VLAN tagged with Ethertype
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Provision_Match_Ethertype_VLAN_tagged_RLT_SR_2492
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match VLAN plus Ethertype, confirm provision completed.
    ...    2	Provision match rule match VLAN and different Ethertype with different match rule ID, confirmed the provision is accepted.
    ...    3	Provision match rule match VLAN and same Ethertype with different match rule ID (duplicate), confirmed the provision is rejected.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-961    @globalid=2316419    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-961 setup
    [Teardown]   AXOS_E72_PARENT-TC-961 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes
    log    STEP:1 Provision match rule match VLAN plus Ethertype, confirm provision completed.

    log    STEP:2 Provision match rule match VLAN and different Ethertype with different match rule ID, confirmed the provision is accepted.

    log    STEP:3 Provision match rule match VLAN and same Ethertype with different match rule ID (duplicate), confirmed the provision is rejected.


    log    STEP:1. match rules: tag;
    log    serivce 1
    log    configure class-map match tag success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_data_cvlan1}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_data_cvlan1}
    log    ${class_map_result}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    ethertype=${rule_ethertype_pppdisc}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    ethertype=${rule_ethertype_pppdisc}
    log    ${class_map_result}
    log    duplicate ethertype would be rejected
    ${result}    prov_class_map_without_error_check    eutA    ${class_map_name_check}    ethernet    flow     1    3    ethertype=${rule_ethertype_pppdisc}
    should contain    ${result}    ${cli_error_msg_eth}





*** Keyword ***
AXOS_E72_PARENT-TC-961 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-961 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

