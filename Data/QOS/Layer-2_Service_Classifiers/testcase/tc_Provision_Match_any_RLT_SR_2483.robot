*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
Documentation     This test case is to confirm provision match rule match any under class-map.
*** Variables ***

*** Test Cases ***
tc_Provision_Match_any_RLT_SR_2483
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match any, confirm provision complete.
    ...    2	Provision match rule match any with different index (duplicate), confirmed the provision is rejected.
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-946    @globalid=2316404    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-946 setup
    [Teardown]   AXOS_E72_PARENT-TC-946 teardown
    log    STEP:

    log    STEP:1 Provision match rule match untagged, confirm provision complete.

    log    STEP:2 Inject untagged traffic, confirm the traffic passes through.

    log    STEP:3 Inject not-untagged traffic, confirm the traffic is dropped.


    log    STEP:1. match rules: any tag;
    log    serivce 1
    log    configure class-map match any success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-946 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-946 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

