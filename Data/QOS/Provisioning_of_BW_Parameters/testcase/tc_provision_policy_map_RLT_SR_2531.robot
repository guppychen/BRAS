*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision policy map works.
*** Variables ***

*** Test Cases ***
tc_provision_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision policy-map, confirm provision works fine.		
    ...    2	Provision policy-map with long name, confirm AXOS accepts max length name for policy-map.					
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-986    @globalid=2316448    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-986 setup
    [Teardown]   AXOS_E72_PARENT-TC-986 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes


    log    STEP:1 Provision policy-map, confirm provision works fine.

    log    STEP:2 Provision policy-map with long name, confirm AXOS accepts max length name for policy-map.


    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_long}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_long}    1    1    any=${EMPTY}
    log    ${class_map_result}
    log    create policy-map with the class map created
    prov_policy_map    eutA    ${policy_map_name_long}    class-map-ethernet    ${class_map_name_long}    flow     1    set-stag-pcp=${stag_pcp}
    ${result}    cli    eutA    show run policy-map ${policy_map_name_long}
    should contain    ${result}    policy-map ${policy_map_name_long}
    should contain    ${result}    class-map-ethernet ${class_map_name_long}





*** Keyword ***
AXOS_E72_PARENT-TC-986 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-986 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name_long}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_long}

