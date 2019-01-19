*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm numbers of class-map provision works.
*** Variables ***

*** Test Cases ***
tc_scale_provision_class_map
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision numbers of class-map on the system (or up to max number supported), confirm the provision works.		
    ...    2	Delete all the class-maps, confirm deletion complete.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1013    @globalid=2316475    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1013 setup
    [Teardown]   AXOS_E72_PARENT-TC-1013 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision numbers of class-map on the system (or up to max number supported), confirm the provision works.

    log    STEP:2 Delete all the class-maps, confirm deletion complete.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    :FOR    ${index}    IN RANGE    ${classmap_profile_num}
    \    prov_class_map    eutA    ${class_map_name_check}_${index}    ethernet    flow     1    1    any=${EMPTY}
    \    log    check class-map etherent configured
    \    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}_${index}    1    1    any=${EMPTY}
    \    log    ${class_map_result}

    log    remove class-map
    :FOR    ${index}    IN RANGE    ${classmap_profile_num}
    \    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}_${index}







*** Keyword ***
AXOS_E72_PARENT-TC-1013 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1013 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    :FOR    ${index}    IN RANGE    ${classmap_profile_num}
    \    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}_${index}
