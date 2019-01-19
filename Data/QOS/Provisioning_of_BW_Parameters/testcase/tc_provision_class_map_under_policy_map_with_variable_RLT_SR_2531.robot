*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision "variable" as a part of class-map provision.
*** Variables ***

*** Test Cases ***
tc_provision_class_map_under_policy_map_with_variable_RLT_SR_2531
    [Documentation]    	
    ...    #	Action	Expected Result	Notes
    ...    1	Provision policy-map, then create class-map. Provision some parameter, for example add-cevlan-tag with variable. Confirm the provision complete.
    ...    2	Confirm all the parameter that support variable works. Example: CEVLAN, CEVLAN-PCP, CTAG, CTAGPCP, STAG, STAGPCP, etc.			
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-991    @globalid=2316453    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-991 setup
    [Teardown]   AXOS_E72_PARENT-TC-991 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision policy-map, then create class-map. Provision some parameter, for example add-cevlan-tag with variable. Confirm the provision complete.

    log    STEP:2 Confirm all the parameter that support variable works. Example: CEVLAN, CEVLAN-PCP, CTAG, CTAGPCP, STAG, STAGPCP, etc.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}

    log    check the parameters under policy map
    log    check add-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    add-cevlan-tag=${p_match_vlan1}    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    add-cevlan-tag\\s+${p_match_vlan1}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}
    log    remove ctag and pcp
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    add-cevlan-tag=${EMPTY}
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    set-ctag-pcp=${EMPTY}
    log    check ctag and pcp are removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not match regexp    ${result}    add-cevlan-tag\\s+${ctag_pcp}
    should not match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}


    log    check remove-cevlan
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    remove-cevlan=${EMPTY}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    remove-cevlan
    log    remove ctag and pcp
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    remove-cevlan=${EMPTY}
    log    check cevlan is removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not contain    ${result}    remove-cevlan




    log    check set-cevlan-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-cevlan-pcp=${cetag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-cevlan-pcp\\s+${cetag_pcp}
    log    remove set-cevlan-pcp
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    set-cevlan-pcp=${EMPTY}
    log    check set-cevlan-pcp is removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not contain    ${result}    set-cevlan-pcp


    log    check set-ctag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}
    log    remove set-cevlan-pcp
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    set-ctag-pcp=${EMPTY}
    log    check set-ctag-pcp is removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not contain    ${result}    set-ctag-pcp


    log    check set-stag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-stag-pcp\\s+${stag_pcp}
    log    remove set-stag-pcp
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    set-stag-pcp=${EMPTY}
    log    check set-stag-pcp is removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not contain    ${result}    set-stag-pcp

    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    translate-cevlan-tag=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    translate-cevlan-tag\\s+${stag_pcp}
    log    remove translate-cevlan-tag
    ${result}    dprov_policy_map    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow    1    translate-cevlan-tag=${EMPTY}
    log    check translate-cevlan-tag is removed
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should not contain    ${result}    translate-cevlan-tag


*** Keyword ***
AXOS_E72_PARENT-TC-991 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-991 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

