*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${minimum_bin_count}    4

*** Test Cases ***
tc_ONT_PM_The_Calix_Platform_when_supporting_a_PM_session_Measurement_Intervals_with_the_following_constraints_15_minutes_will_require_a_minimum_of_4_historical_bins
    [Documentation]    A Measurement Interval of: 15 minutes will require a minimum of 4 historical bins
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-778    @globalid=2307638
    [Setup]      setup
    [Teardown]   teardown
    log    STEP:A Measurement Interval of: 15 minutes will require a minimum of 4 historical bins
    Axos Cli With Error Check    eutA    configure
    ${bin_cnt_str}    release_cmd_adapter    eutA    ${prov_interface_pon_config_rmon_session_bin_count}    3    
    ${output}    Cli    eutA    ont ${service_model.subscriber_point1.attribute.ont_id} rmon-session ${rmon_session_15_min} ${bin_cnt_str}    
    ${res}    Should Match Regexp    ${output}    Minimum value needed for the specified bin_duration is (\\d+)
    Should Be Equal    ${minimum_bin_count}    @{res}[1]
    Axos Cli With Error Check    eutA    end
    prov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}    ${minimum_bin_count}
    log    The minimum input is ${minimum_bin_count}.


*** Keywords ***
setup
    [Documentation]
    [Arguments]
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}

teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_15_min}     ${minimum_bin_count}