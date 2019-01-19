*** Settings ***
Documentation     This test case is to confirm AXOS accepts any combination of match creteria, unless this is inhibited (for example, duplicate rules).
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Calix_match_rules_MUST_support_combinations_of_any_valid_match_criterion_unless_specifically_excluded_by_other_SR
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision multiple match rules under single flow, confirm any combination of much rule can be created under single flow.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-975    @globalid=2316433    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-975 setup
    [Teardown]   AXOS_E72_PARENT-TC-975 teardown
    log    STEP:
    log    STEP:1 Provision match rule match VLAN with PCP, confirm provision completed.

    log    STEP:2 Provision match rule match VLAN (same VLAN) with different PCP with different match rule ID, confirmed the provision is accepted.

    log    STEP:3 Provision match rule match VLAN with PCP (same VLAN, same PCP) with different match rule ID (duplicate), confirmed the provision is rejected.


    log    STEP:1. match rules: tag tag;
    log    serivce 1
    log    configure class-map match vlan success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    ${class_map_result}
    log    configure class-map match eth-type success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    ethertype=${rule_ethertype_pppdisc}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    ethertype=${rule_ethertype_pppdisc}
    log    ${class_map_result}
    log    configure class-map match priority tagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    3    priority-tagged=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    3    priority-tagged=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    4    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    4    any=${EMPTY}
    log    ${class_map_result}






*** Keyword ***
AXOS_E72_PARENT-TC-975 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-975 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

