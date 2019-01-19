*** Settings ***
Documentation     
Resource          ./base.robot


*** Variables ***
${bin_count}    1


*** Test Cases ***
tc_PON_PM_The_Calix_Platform_when_supporting_a_PM_session_with_historical_bins_MUST_provide_a_minimum_of_1_hour_of_historical_bin_data_supporting_Measurement_Intervals_with_the_following_constraints_24_hours_will_require_minimum_of_1_historical_bin
    [Documentation]    One hour will require minimum of 1 historical bin
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-776    @globalid=2307636
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:One hour will require minimum of 1 historical bin
    Axos Cli With Error Check    eutA    configure
    ${bin_cnt_str}    release_cmd_adapter    eutA    ${prov_interface_pon_config_rmon_session_bin_count}    0
    ${output}    Cli    eutA    interface pon ${pon_port} rmon-session ${rmon_session_1_hour} ${bin_cnt_str}
    Should Contain    ${output}    syntax error: "0" is out of range.
    Axos Cli With Error Check    eutA    end   
    prov_pon_pm    eutA     ${pon_port}    ${rmon_session_1_hour}    ${bin_count}
    log    The supported minimum input is ${bin_count}.

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    setup
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log     step1: create a class-map to match VLAN 600 in flow 1
    log     step2: create a policy-map to bind the class-map and add c-tag
    log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
    log     step4: apply the s-tag and policy-map to the port of ont
    subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    Set Test Variable    ${pon_port}    ${pon_port}
    log    Add pm task to pon port.

case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    Axos Cli With Error Check    eutA    configure
    Axos Cli With Error Check    eutA    no interface pon ${pon_port} rmon-session
    Axos Cli With Error Check    eutA    end  
    ${res1}    Cli    eutA    show running-config interface pon ${pon_port} rmon-session     
    Should Contain    ${res1}    No entries found