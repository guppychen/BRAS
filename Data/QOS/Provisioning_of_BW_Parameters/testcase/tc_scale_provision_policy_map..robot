*** Settings ***
Resource          base.robot
Force Tags        @feature=Qos    @subfeature=Provisioning_of_BW_Parameters    @author=Yuanwu
Documentation     This test case is to confirm numbers of policy map provision works.
*** Variables ***

*** Test Cases ***
tc_scale_provision_policy_map
    [Documentation]    #	Action	Expected Result	Notes
    ...    1	Provision numbers of policy map on the system, confirm all the provision works.		
    ...    2	Delete all the policy map provisioned on the system, confirm deletion works.			
    [Tags]       @author=ywu     @TCID=AXOS_E72_PARENT-TC-1014    @globalid=2316476    @priority=P2    @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1014 setup
    [Teardown]   AXOS_E72_PARENT-TC-1014 teardown
    log    STEP:
    log    STEP:# Action Expected Result Notes

    log    STEP:1 Provision numbers of policy map on the system, confirm all the provision works.

    log    STEP:2 Delete all the policy map provisioned on the system, confirm deletion works.



    log    STEP:1. match rules: match any;
    log    provision class-map
    log    configure class-map match any success
    prov_class_map    eutA     ${class_map_name_check}  ethernet    flow     1    1    any=${EMPTY}
    log    check class-map etherent configured
    ${class_map_result}    check_classmap_ethternet    eutA     ${class_map_name_check}    1    1    any=${EMPTY}
    log    ${class_map_result}
    :FOR    ${index}    IN RANGE    ${policymap_profile_num}
    \    log    create policy-map with the class map created
    \    prov_policy_map    eutA    ${policy_map_name}_${index}    class-map-ethernet     ${class_map_name_check}    flow     1    set-stag-pcp=${stag_pcp}
    \    ${result}    cli    eutA    show run policy-map ${policy_map_name}_${index}
    \    should contain    ${result}    policy-map ${policy_map_name}_${index}
    \    should contain    ${result}    class-map-ethernet  ${class_map_name_check}

    log    remove class map and policy map
    :FOR    ${index}    IN RANGE    ${policymap_profile_num}
    \    delete_config_object    eutA    policy-map    ${policy_map_name}_${index}
    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}


*** Keyword ***
AXOS_E72_PARENT-TC-1014 setup
    [Documentation]    test case setup
    [Arguments]
    log    no provision for set up



AXOS_E72_PARENT-TC-1014 teardown
    [Documentation]    test case teardown
    [Arguments]
    log    remove class-map
    :FOR    ${index}    IN RANGE    ${policymap_profile_num}
    \    run keyword and ignore error    delete_config_object    eutA    policy-map    ${policy_map_name}_${index}
    run keyword and ignore error    delete_config_object    eutA    class-map    ethernet ${class_map_name_check}

