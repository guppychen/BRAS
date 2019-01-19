*** Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM

*** Variables ***
${bin_duration}    15
${bin_count}    4



*** Test Cases ***
tc_R300_A_PM_Session_MUST_Specify_a_Historical_Number_of_Measurement_Intervals_to_store_Range_4
    [Documentation]    A PM Session will have a defined number of Historical Bins. The case is 1, but actually the 15-min bin support a minimum of 4.
    ...    Step 1: Provision a rmon-session on the PON interface, set requested bin count to 4.
    ...    Step 2: Check the bin count after the first bin completes and the second bin starts.
    ...    Step 3: Check all of the 4 bins can be restored. (This step needs 1 hour to finsih, so I marked them off temporarily.)
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-757   @globalid=2307617    @eut=NGPON2-4    @priority=P1
    
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    ${bin_number}    get_latest_pm_bin_number    eutA    ${pon_port}     ${rmon_session_15_min}     ${rmon_type}    ${num_back}    ${num_show}
    Bin Wait Time   ${bin_duration}
    ${bin_number_next}    get_latest_pm_bin_number    eutA    ${pon_port}     ${rmon_session_15_min}     ${rmon_type}    ${num_back}    ${num_show}
    ${num1}    Convert to Integer    ${bin_number}
    ${num2}    Convert To Integer    ${bin_number_next}
    ${var}    Evaluate    ${num2} - 1
    Should Be Equal    ${var}    ${num1}
    
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
#     set test variable    ${pon_port}    ${pon_port}
     log    Add pm task to pon port.
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

teardown
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}