*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${minimum_bin_count}    1


*** Test Cases ***
tc_ONT_PM_The_Calix_Platform_when_supporting_a_PM_session_Measurement_Intervals_with_the_following_constraints_60_minutes_will_require_a_minimum_of_1_historical_bin
    [Documentation]    A Measurement Interval of: 60 minutes will require a minimum of 1 historical bin
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-779    @globalid=2307639
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:A Measurement Interval of: 60 minutes will require a minimum of 1 historical bin
    Axos Cli With Error Check    eutA    configure
    ${bin_cnt_str}    release_cmd_adapter    eutA    ${prov_interface_pon_config_rmon_session_bin_count}    0    
    ${output}    Cli    eutA    ont ${service_model.subscriber_point1.attribute.ont_id} rmon-session ${rmon_session_1_hour} ${bin_cnt_str}
    Should Contain    ${output}    out of range
    Axos Cli with Error Check    eutA    end
    prov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_1_hour}    ${minimum_bin_count}
    log    The minimum input is ${minimum_bin_count}.


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}

case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_ont_pm    eutA    ${service_model.subscriber_point1.attribute.ont_id}    ${rmon_session_1_hour}     ${minimum_bin_count}