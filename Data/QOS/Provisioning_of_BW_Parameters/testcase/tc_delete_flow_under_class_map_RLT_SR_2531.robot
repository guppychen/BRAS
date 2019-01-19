*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm deletion of flow under class-map.
*** Variables ***

*** Test Cases ***
tc_delete_flow_under_class_map_RLT_SR_2531
    [Documentation]    	
    ...    #	Action	Expected Result	Notes
    ...    1	Provision class-map and create a couple of flows, delete the flows, confirm flow deletion works fine.		
    ...    2	Try to add/delete flow several times and confirm the operation works fine.					
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-984    @globalid=2316446    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-984 setup
    [Teardown]   AXOS_E72_PARENT-TC-984 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision class-map and create a couple of flows, delete the flows, confirm flow deletion works fine.

    log    STEP:2 Try to add/delete flow several times and confirm the operation works fine.



    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match untagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    untagged=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    untagged=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match tagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    3    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    3    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    ${class_map_result}
    log    configure class-map with ether-type
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    4    ethertype=${rule_ethertype_pppdisc}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    4    ethertype=${rule_ethertype_pppdisc}
    log    ${class_map_result}


    log    delete rules from class-map and check result
    ${result}    dprov_class_map    eutA    ${class_map_name_check}    ethernet    flow    1    rule=1
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}
    log    ${class_map_result}
    should not contain    ${class_map_result}    any




*** Keyword ***
AXOS_E72_PARENT-TC-984 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-984 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

