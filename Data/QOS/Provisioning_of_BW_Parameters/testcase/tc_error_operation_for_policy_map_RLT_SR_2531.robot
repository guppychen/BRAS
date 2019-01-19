*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm error operation for policy map is properly rejected and AXOS provides proper error message.
...    Followings are the example of error operations.
...     
...    * Try to delete policy map that is referred by interface or VLAN.
...    * Try to delete policy map that has child object exist.
...    * Try to delete policy map that doesn't exist.
*** Variables ***

*** Test Cases ***
tc_error_operation_for_policy_map_RLT_SR_2531
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Try to execute error operation for policy map as example in description, confirm AXOS provides rejects the operation and provide proper error message.		
    ...    2	Try to execute error operation for policy map as example in description, confirm the system status back as same as before operation (roll back).		
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-988    @globalid=2316450    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-988 setup
    [Teardown]   AXOS_E72_PARENT-TC-988 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Try to execute error operation for policy map as example in description, confirm AXOS provides rejects the operation and provide proper error message.

    log    STEP:2 Try to execute error operation for policy map as example in description, confirm the system status back as same as before operation (roll back).


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
    should contain    ${result}    set-stag-pcp  ${stag_pcp}
    log    add policy map to ont port
    subscriber_point_add_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}


    log    remove policy map when it is used by ont port
    ${result}    delete_config_object_without_error_check    eutA    policy-map    ${policy_map_name}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:
    log    remove policy map does not exist
    ${result}    delete_config_object_without_error_check    eutA    policy-map    ${class_map_name_noexist}
    log    check the error message
    Should Contain Any    ${result}    Invalid    syntax error    Aborted:    Error:



*** Keyword ***
AXOS_E72_PARENT-TC-988 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up
    prov_vlan    eutA    ${p_data_vlan1}
    prov_vlan    eutA    ${p_data_vlan2}
    prov_vlan    eutA    ${p_data_vlan3}

AXOS_E72_PARENT-TC-988 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${p_data_vlan1}    ${policy_map_name}
    delete_config_object    eutA    policy-map    ${policy_map_name}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}


    log    delete vlan
    delete_config_object    eutA    vlan    ${p_data_vlan1}
    delete_config_object    eutA    vlan    ${p_data_vlan2}
    delete_config_object    eutA    vlan    ${p_data_vlan3}
