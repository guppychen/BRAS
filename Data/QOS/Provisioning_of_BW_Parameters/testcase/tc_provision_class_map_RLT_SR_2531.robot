*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision class-map works.
*** Variables ***

*** Test Cases ***
tc_provision_class_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision class-map, confirm provision works fine.
    ...    2	Provision class-map with long name, confirm AXOS accepts max length name for class-map.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-976    @globalid=2316438    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-976 setup
    [Teardown]   AXOS_E72_PARENT-TC-976 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision class-map, confirm provision works fine.

    log    STEP:2 Provision class-map with long name, confirm AXOS accepts max length name for class-map.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_long}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_long}    1    1    any=${EMPTY}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-976 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-976 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    class-map    ethernet ${class_map_name_long}

