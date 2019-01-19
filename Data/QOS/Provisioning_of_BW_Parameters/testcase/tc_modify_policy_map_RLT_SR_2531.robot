*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm modify policy map works.
...     
...    This test case is to confirm modify policy map.
...    At this moment, I see only class-map under policy-map.
...    This test case is created if any other parameter is supported other than class-map.
*** Variables ***

*** Test Cases ***
tc_modify_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Modify any parameter under policy-map, confirm the modification works if that is acceptable change.				
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-987    @globalid=2316449    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-987 setup
    [Teardown]   AXOS_E72_PARENT-TC-987 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Modify any parameter under policy-map, confirm the modification works if that is acceptable change.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}
    should contain    ${result}    set-stag-pcp  ${stag_pcp}


    log    modify policy-map set-stag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-stag-pcp=${ctag_pcp}
    log    check policy-map
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}
    should contain    ${result}    set-stag-pcp  ${ctag_pcp}



*** Keyword ***
AXOS_E72_PARENT-TC-987 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-987 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

