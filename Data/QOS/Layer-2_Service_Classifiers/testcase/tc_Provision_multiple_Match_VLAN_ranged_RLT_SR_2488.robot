*** Settings ***
Documentation     This test case is to confirm provision match rule with ranged VLAN under class-map.
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Provision_multiple_Match_VLAN_ranged_RLT_SR_2488
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match ranged VLAN (e.g. VLAN 101-200), confirm provision complete.		
    ...    2	Provision match rule that is fully or partially duplicated VLAN ID with above with different match rule ID, confirm provision is rejected.			
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-955    @globalid=2316413    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-955 setup
    [Teardown]   AXOS_E72_PARENT-TC-955 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision match rule match ranged VLAN (e.g. VLAN 101-200), confirm provision complete.

    log    STEP:2 Provision match rule that is fully or partially duplicated VLAN ID with above with different match rule ID, confirm provision is rejected.


    log    STEP:1. match rules: tag tag;

    log    configure class-map match vlan success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_match_vlan1}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_match_vlan1}
    log    ${class_map_result}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    vlan=${p_match_vlan2}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    vlan=${p_match_vlan2}
    log    ${class_map_result}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    3    vlan=${p_match_vlan3}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    3    vlan=${p_match_vlan3}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-955 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-955 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

