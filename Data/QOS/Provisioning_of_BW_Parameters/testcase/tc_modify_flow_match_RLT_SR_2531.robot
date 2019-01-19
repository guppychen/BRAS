*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision various match list.
*** Variables ***

*** Test Cases ***
tc_modify_flow_match_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision flow and specify various match, then modify some of match rules, confirm modification works.		
    ...    2	try to match one of match rules as same as other, confirm the operation is rejected properly.				
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-983    @globalid=2316445    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-983 setup
    [Teardown]   AXOS_E72_PARENT-TC-983 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes


    log    STEP:1 Provision flow and specify various match, then modify some of match rules, confirm modification works.

    log    STEP:2 try to match one of match rules as same as other, confirm the operation is rejected properly.




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


    log    modify flow and check result

    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    untagged=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    untagged=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match untagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    any=${EMPTY}
    log    ${class_map_result}
    log    configure class-map match tagged success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    3    vlan=${p_match_vlan2}    pcp=${match_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    3    vlan=${p_match_vlan2}    pcp=${match_pcp}
    log    ${class_map_result}
    log    configure class-map with ether-type
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    4    ethertype=${rule_ethertype_pppsesion}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    4    ethertype=${rule_ethertype_pppsesion}
    log    ${class_map_result}




*** Keyword ***
AXOS_E72_PARENT-TC-983 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-983 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

