*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm error operation against flow is rejected with proper error message.
...     
...    Followings are example of error operation.
...    * Delete flow that is referred by other instance, such as VLAN IF.
...    * Delete flow that has child object exist
...    * Delete flow that doesn't exist.
*** Variables ***

*** Test Cases ***
tc_error_operation_for_flow_under_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Try the error operation as example in description, confirm the operation is rejected with properly error message.		
    ...    2	Try the error operation, confirm the status back as before the operation (roll back).		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-996    @globalid=2316458    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-996 setup
    [Teardown]   AXOS_E72_PARENT-TC-996 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Try the error operation as example in description, confirm the operation is rejected with properly error message.

    log    STEP:2 Try the error operation, confirm the status back as before the operation (roll back).


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    set-stag-pcp=${stag_pcp}


    log    remove class-map referenced by policy map
    ${result}    delete_config_object_without_error_check    eutA    class-map    ethernet ${class_map_name_check}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:





    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     2    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     3    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     4    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     5    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     6    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     7    1    any=${EMPTY}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     8    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    2    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    3    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    4    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    5    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    6    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    7    1    any=${EMPTY}
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    8    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    policy-map ${policy_map_name}
    should contain    ${result}    class-map-ethernet ${class_map_name_check}


    log    provision flow 1 with add-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    add-cevlan-tag=${p_match_vlan1}    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    add-cevlan-tag\\s+${p_match_vlan1}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}


    log    provision flow 2 with remove-cevlan
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     2    remove-cevlan=${EMPTY}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should contain    ${result}    remove-cevlan




    log    provision flow 3 with set-cevlan-pcp
    log    check set-cevlan-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     3    set-cevlan-pcp=${cetag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-cevlan-pcp\\s+${cetag_pcp}


    log    provision flow 4 with set-ctag-pcp
    log    check set-ctag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     4    set-ctag-pcp=${ctag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-ctag-pcp\\s+${ctag_pcp}



    log    provision flow 5 with set-stag-pcp
    log    check set-stag-pcp
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     5    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    set-stag-pcp\\s+${stag_pcp}


    log    provision flow 6 with translate-cevlan-tag
    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     6    translate-cevlan-tag=${p_data_vlan1}
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 6
    should match regexp    ${result}    translate-cevlan-tag\\s+${p_data_vlan1}



    log    provision flow 7 with translate-cevlan-tag and set s tag
    log    check translate-cevlan-tag
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     7    translate-cevlan-tag=${p_data_vlan1}    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 7
    should match regexp    ${result}    translate-cevlan-tag\\s+${p_data_vlan1}
    should match regexp    ${result}    set-stag-pcp\\s+${stag_pcp}


#    log    provision flow 8 with translate-cevlan-tag and set c tag
#    log    cevlan/cevlan_pcp and ctag/pcp combination are rejected
#    log    check translate-cevlan-tag
#    ${result}    prov_policy_map_without_error_check    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     8    translate-cevlan-tag=${p_data_vlan1}    set-ctag-pcp=${ctag_pcp}
#    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:


    log    delete rules from policy-map that not exist
    ${result}    dprov_policy_map_without_error_check    eutA    ${policy_map_name}     class-map-ethernet    ${class_map_name_check}    flow=9
    ${result}    cli    eutA    show run policy-map ${policy_map_name} class-map-ethernet flow 9
    run keyword and ignore error    should not match regexp    ${result}    flow\\s+9






*** Keyword ***
AXOS_E72_PARENT-TC-996 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-996 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

