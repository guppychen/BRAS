*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision flow under class-map.
*** Variables ***

*** Test Cases ***
tc_Provision_flow_under_class_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision class-map, then flow, confirm flow provision works.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-980    @globalid=2316442    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-980 setup
    [Teardown]   AXOS_E72_PARENT-TC-980 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision class-map, then flow, confirm flow provision works.



    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match untagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     2    1    untagged=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    2    1    untagged=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match tagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     3    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    3    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    ${class_map_result}







*** Keyword ***
AXOS_E72_PARENT-TC-980 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-980 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

