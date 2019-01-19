*** Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM

*** Variables ***
${bin_duration}    15
${bin_count}    1440
# ${pon_counter_name}    rx-errors



*** Test Cases ***
tc_R300_A_PM_Session_MUST_Specify_a_Historical_Number_of_Measurement_Intervals_to_store_Range_1440
    [Documentation]    A PM Session will have a defined number of Historical Bins. In this test, the value is the max, 1440.
    ...    Step 1: Provision a rmon-session on the PON interface, set requested bin count to 1440.
    ...    Step 2: The cli command can be executed successfully.
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-760   @globalid=2307620    @eut=NGPON2-4    @priority=P1

    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}
    log    Rmon-session has been removed.
    ${bin_count1}    Evaluate    ${bin_count} + 1
    Axos Cli With Error Check    eutA    configure
    ${bin_cnt_str}    release_cmd_adapter    eutA    ${prov_interface_pon_config_rmon_session_bin_count}    ${bin_count1}
    ${output}     Cli    eutA    interface pon ${pon_port} rmon-session ${rmon_session_15_min} ${bin_cnt_str}
    Should Contain    ${output}    out of range
    
*** Keywords ***
setup
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step1: create a class-map to match VLAN 600 in flow 1
     log     step2: create a policy-map to bind the class-map and add c-tag
     log     step3: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     log     step4: apply the s-tag and policy-map to the port of ont
     subscriber_point_add_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
     ${var}    subscriber_point_get_pon_port_name    subscriber_point1
     set test variable    ${pon_port}    ${var}
     log    Add pm task to pon port.
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}


teardown
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    Axos Cli With Error Check    eutA    configure
    Axos Cli With Error Check    eutA    no interface pon ${pon_port} rmon-session
    
