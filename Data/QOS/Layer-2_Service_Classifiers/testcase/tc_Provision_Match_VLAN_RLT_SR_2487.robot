*** Settings ***
Documentation     This test case is to confirm provision match rule match untagged under class-map.
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Provision_Match_VLAN_RLT_SR_2487
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match VLAN 20, confirm provision complete.
    ...    2	Provision match rule match VLAN 20 with different index (duplicate), confirmed the provision is rejected.
    ...    3	Provision match rule match VLAN 25 with different index (duplicate), confirmed the provision is accepted.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-953    @globalid=2316411    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-953 setup
    [Teardown]   AXOS_E72_PARENT-TC-953 teardown
    log    STEP:
    log    STEP:1 Provision match rule match VLAN 20, confirm provision complete.

    log    STEP:2 Provision match rule match VLAN 20 with different index (duplicate), confirmed the provision is rejected.

    log    STEP:3 Provision match rule match VLAN 25 with different index (duplicate), confirmed the provision is accepted.


    log    STEP:1. match rules: tag tag;
    log    serivce 1
    log    configure class-map match vlan success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_match_vlan1}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_match_vlan1}
    log    ${class_map_result}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    vlan=${p_match_vlan2}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    vlan=${p_match_vlan2}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-953 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-953 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

