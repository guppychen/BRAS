*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision egress shaper under class map.
*** Variables ***

*** Test Cases ***
tc_provision_egress_shaper_bandwidth_under_policy_map_class_map_RLT_SR_2532_RLT_SR_2535_RLT_SR_2536
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision policy-map, class map. Provision egress --> shaper, confirm provision works.		
    ...    2	Provision multiple flows under class-map, provision egress shaper bandwidth on each flows, confirm provision works.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-999    @globalid=2316461    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-999 setup
    [Teardown]   AXOS_E72_PARENT-TC-999 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision policy-map, class map. Provision egress --> shaper, confirm provision works.

    log    STEP:2 Provision multiple flows under class-map, provision egress shaper bandwidth on each flows, confirm provision works.


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



    log    provision policy with egress meter cir and eir
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    egress shaper    minimum=${cir_value}    maximum=${eir_value}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    egress shaper
    should match regexp    ${result}    maximum\\s+${eir_value}
    should match regexp    ${result}    minimum\\s+${cir_value}


*** Keyword ***
AXOS_E72_PARENT-TC-999 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-999 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

