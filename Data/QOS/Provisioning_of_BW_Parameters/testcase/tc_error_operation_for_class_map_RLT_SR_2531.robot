*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm the operation is rejected properly for error case.
*** Variables ***

*** Test Cases ***
tc_error_operation_for_class_map_RLT_SR_2531
    [Documentation]    Followings are the example of error operation.
    ...     
    ...    * Try to delete class-map with existing child object.
    ...    * Try to delete class-map while it is referred by policy map.
    ...    * Try to delete non-existing class-map.
    ...    #	Action	Expected Result	Notes
    ...    1	Error operation as example in description, confirm AXOS shows error properly.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-979    @globalid=2316441    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-979 setup
    [Teardown]   AXOS_E72_PARENT-TC-979 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Error operation as example in description, confirm AXOS shows error properly.


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
    log    remove class-map not exist
    ${result}    delete_config_object_without_error_check    eutA    class-map    ethernet ${class_map_name_noexist}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:





*** Keyword ***
AXOS_E72_PARENT-TC-979 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-979 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

