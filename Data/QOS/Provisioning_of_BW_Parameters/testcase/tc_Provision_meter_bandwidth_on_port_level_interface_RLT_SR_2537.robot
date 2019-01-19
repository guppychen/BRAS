*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm provision ingress meter to port level interface.
*** Variables ***

*** Test Cases ***
tc_Provision_meter_bandwidth_on_port_level_interface_RLT_SR_2537
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision ingress --> meter on port interface level, confirm provision complete.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1020    @globalid=2316482    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1020 setup
    [Teardown]   AXOS_E72_PARENT-TC-1020 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes


    log    STEP:1 Provision ingress --> meter on port interface level, confirm provision complete.


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

    log    provision flow 1 with ingress meter cir and eir
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    ingress-meter cir=${flow_cir_value}
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    flow     1    ingress-meter eir=${flow_eir_value}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    ingress-meter\\s+cir\\s+${flow_cir_value}
    should match regexp    ${result}    ingress-meter\\s+eir\\s+${flow_eir_value}

    log    provision policy with ingress meter cir and eir
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_check}    ingress meter-mef    cir=${cir_value}    eir=${eir_value}
    ${result}    cli    eutA    show run policy-map ${policy_map_name}
    should match regexp    ${result}    ingress meter-mef\\r\\n\\s+cir\\s+${cir_value}\\r\\n\\s+eir\\s+${eir_value}


*** Keyword ***
AXOS_E72_PARENT-TC-1020 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1020 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

