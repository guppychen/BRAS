***Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM
*** Variables ***
${bin_count}    1440
${pon_counter_name}    rx-discards



*** Test Cases ***
tc_Each_PON_OLT_Interface_MUST_support_a_PM_Session_collecting_the_Performance_Monitoring_Statistics_data_defined_in_the_RFC_7223_standard_for_Interface_Packet_and_Octet_counters_in_discards_counter32
    [Documentation]    To verify the AXOS NGPON system support collecting RFC7223 counters.
    ...    Step 1: Provision a rmon-session on the PON interface.
    ...    Step 2: Change the admin-state to disable.
    ...    Step 3: Check the running config to confirm the change is taking effect.
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-785   @globalid=2307645    @eut=NGPON2-4    @priority=P5
    
    ${output}    Cli    eutA    show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session_15_min} bin-or-interval ${rmon_type} num-back ${num_back} num-show ${num_show}
    log    The PM result is ${output}
    Should Match Regexp   ${output}    ${pon_counter_name}\\s+\\d+
 
*** Keywords ***
setup
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
     log    Add pm task to pon port.
     Set Test Variable    ${pon_port}    ${pon_port}
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

teardown
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}      Cases ***