*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm deleting class-map works
*** Variables ***

*** Test Cases ***
tc_delete_class_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Delete existing class map, confirm operation complete.		
    ...    2	Delete existing class map, the class map is gone properly.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-978    @globalid=2316440    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-978 setup
    [Teardown]   AXOS_E72_PARENT-TC-978 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Delete existing class map, confirm operation complete.

    log    STEP:2 Delete existing class map, the class map is gone properly.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    remove class-map
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}
    log    check class-map deleted
    ${result}    cli    eutA    show running-config class-map ethernet ${class_map_name_check}
    should contain    ${result}    error    # Updated by AT-5936
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:






*** Keyword ***
AXOS_E72_PARENT-TC-978 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-978 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

