*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm deleting class-map under policy map not works.
*** Variables ***

*** Test Cases ***
tc_delete_class_map_from_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision policy-map, create class-map. Delete the class-map, confirm the deletion not works. error message would prompt.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-992    @globalid=2316454    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-992 setup
    [Teardown]   AXOS_E72_PARENT-TC-992 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision policy-map, create class-map. Delete the class-map, confirm the deletion not works. error message would prompt.


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






*** Keyword ***
AXOS_E72_PARENT-TC-992 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-992 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

