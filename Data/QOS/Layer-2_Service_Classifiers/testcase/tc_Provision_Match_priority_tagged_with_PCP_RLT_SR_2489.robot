*** Settings ***
Documentation     This test case is to confirm provision match rule match untagged under class-map.
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***


*** Test Cases ***
tc_Provision_Match_priority_tagged_with_PCP_RLT_SR_2489
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match priority-tagged with PCP, confirm provision complete.		
    ...    2	Provision match rule match priority-tagged (no PCP) with different index, confirmed the provision is accepted.		
    ...    3	Provision match rule match priority-tagged and same PCP with different index (duplicate), confirmed the provision is rejected.			
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-957    @globalid=2316415    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-957 setup
    [Teardown]   AXOS_E72_PARENT-TC-957 teardown
    log    STEP:

    log    STEP:1 Provision match rule match priority-tagged with PCP, confirm provision complete.

    log    STEP:2 Provision match rule match priority-tagged (no PCP) with different index, confirmed the provision is accepted.

    log    STEP:3 Provision match rule match priority-tagged and same PCP with different index (duplicate), confirmed the provision is rejected.


    log    STEP:1. match rules: priority tag pcp;
    log    serivce 1
    log    configure class-map match priority success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    priority-tagged=${EMPTY}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    priority-tagged=${EMPTY}    pcp=${stag_pcp}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-957 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-957 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

