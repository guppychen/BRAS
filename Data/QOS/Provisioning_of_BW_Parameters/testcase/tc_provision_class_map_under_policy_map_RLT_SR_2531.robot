*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision class-map under policy-map.
*** Variables ***

*** Test Cases ***
tc_provision_class_map_under_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision policy-map, then create class-map, confirm provision works.		
    ...    2	Provision multiple class-map under single policy map, confirm the provision complete.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-989    @globalid=2316451    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-989 setup
    [Teardown]   AXOS_E72_PARENT-TC-989 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision policy-map, then create class-map, confirm provision works.


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





*** Keyword ***
AXOS_E72_PARENT-TC-989 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-989 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

