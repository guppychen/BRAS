*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos
Documentation     This test case is to confirm delete VLAN from ONT port works.
*** Variables ***

*** Test Cases ***
tc_delete_VLAN_from_ONT_port
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Assign VLAN on ONT port, then delete the VLAN from ONT port, confirm the deletion works.		
    ...    2	Assign multiple VLANs on ONT port, then delete the VLAN from ONT port, confirm the deletion works.		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1012    @globalid=2316474    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1012 setup
    [Teardown]   AXOS_E72_PARENT-TC-1012 teardown
    
    log    STEP:1 Assign VLAN on ONT port, then delete the VLAN from ONT port, confirm the deletion works.

    log    STEP:2 Assign multiple VLANs on ONT port, then delete the VLAN from ONT port, confirm the deletion works.



    log    STEP:1. match rules: priority tag;
    log    serivce 1
    log    configure class-map match priority success
    prov_class_map    eutA    ${class_map_name_priority}    ethernet    flow     1    1    priority-tagged=${EMPTY}    pcp=${match_pcp}
    log    create policy-map and add svc on ont-ethernet port
    prov_policy_map    eutA    ${policy_map_name}    class-map-ethernet    ${class_map_name_priority}    flow     1    set-stag-pcp=${stag_pcp}
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}

    log    show interface ont port
    ${result}    cli    eutA    show running-config interface ont-ethernet ${service_model.subscriber_point1.name}
    should contain    ${result}    ${policy_map_name}
    should match regexp    ${result}    vlan\\s+${p_data_vlan1}

    log    delete svc
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}


    log    show interface ont port
    ${result}    cli    eutA    show running-config interface ont-ethernet ${service_model.subscriber_point1.name}
    should not contain    ${result}    ${policy_map_name}
    should not match regexp    ${result}    vlan\\s+${p_data_vlan2}


*** Keyword ***
AXOS_E72_PARENT-TC-1012 setup
    [Documentation]    test case setup
    [Arguments]
    log    service_point_provision for uplink side
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


AXOS_E72_PARENT-TC-1012 teardown
    [Documentation]    test case teardown
    [Arguments]


    log    delete svc
    run keyword and ignore error    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    delete_config_object    eutA    class-map    ethernet ${class_map_name_priority}

    log    service_point remove_svc
    service_point_remove_vlan    service_point_list1    ${p_data_vlan1}-${p_data_vlan3}


    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}

