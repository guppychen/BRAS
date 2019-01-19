*** Settings ***
Documentation     This test case is to confirm provision match rule match VLAN with PCP.
Resource          ./base.robot
Force Tags        @feature=Qos    @subfeature=Layer-2_Service_Classifiers    @author=Yuanwu
*** Variables ***

*** Test Cases ***
tc_Provision_Match_VLAN_plus_pcp_RLT_SR_2495
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision match rule match VLAN with PCP, confirm provision completed.		
    ...    2	Provision match rule match VLAN (same VLAN) with different PCP with different match rule ID, confirmed the provision is accepted.		
    ...    3	Provision match rule match VLAN with PCP (same VLAN, same PCP) with different match rule ID (duplicate), confirmed the provision is rejected.				
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-971    @globalid=2316429    @eut=NGPON2-4    @priority=P2
    [Setup]      AXOS_E72_PARENT-TC-971 setup
    [Teardown]   AXOS_E72_PARENT-TC-971 teardown
    log    STEP:
    log    STEP:1 Provision match rule match VLAN with PCP, confirm provision completed.

    log    STEP:2 Provision match rule match VLAN (same VLAN) with different PCP with different match rule ID, confirmed the provision is accepted.

    log    STEP:3 Provision match rule match VLAN with PCP (same VLAN, same PCP) with different match rule ID (duplicate), confirmed the provision is rejected.


    log    STEP:1. match rules: tag tag;
    log    serivce 1
    log    configure class-map match vlan success
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    1    vlan=${p_match_vlan1}    pcp=${stag_pcp}
    log    ${class_map_result}
    prov_class_map    eutA    ${class_map_name_check}    ethernet    flow     1    2    vlan=${p_match_vlan2}    pcp=${stag_pcp}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA    ${class_map_name_check}    1    2    vlan=${p_match_vlan2}    pcp=${stag_pcp}
    log    ${class_map_result}








*** Keyword ***
AXOS_E72_PARENT-TC-971 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side



AXOS_E72_PARENT-TC-971 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    subscriber_point remove_svc and deprovision
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

