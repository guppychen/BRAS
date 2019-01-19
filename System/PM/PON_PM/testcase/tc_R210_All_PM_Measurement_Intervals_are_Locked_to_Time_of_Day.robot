*** Settings ***
Documentation     Each PON OLT Interface MUST support a PM Session collecting the Performance Monitoring Statistics data defined in the RFC 7223 standard for Interface Packet and Octet counters.
Resource          ./base.robot

*** Variables ***
${rmon_session_minute}    15
${bin_count}    4
${bin_duration}    960    # 15min

*** Test Cases ***
tc_R210_All_PM_Measurement_Intervals_are_Locked_to_Time_of_Day
    [Documentation]    For example if the Measurement Interval is 15 minutes then the bin PM collection occurs on the hour, 15 minutes past, 30 minutes past and 45 minutes past the hour. The first Measurement Interval will likely be a partial interval and be marked with a 'Suspect' Flag and elapsed time will indicate the extent of the MI.
    [Tags]       @author=JerryWu     @TCID=AXOS_E72_PARENT-TC-745    @globalid=2307605    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:For example if the Measurement Interval (MI) is 15 minutes then the bin PM collection occurs on the hour, 15 minutes past, 30 minutes past and 45 minutes past the hour. The first Measurement Interval will likely be a partial interval and be marked with a 'Suspect' Flag and elapsed time will indicate the extent of the MI.

    ${input_bin}    get_latest_pm_bin_number    eutA    ${pon_port}    ${rmon_session_15_min}     ${rmon_type}    ${num_back}    ${num_show}
    log    The first bin number is ${input_bin}
    Wait Until Keyword Succeeds    ${bin_duration}    30    pon_pm_bin_complete    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}     ${num_show}    ${input_bin}  
    
    ${res}    Cli    eutA    show interface pon ${pon_port} performance-monitoring rmon-session bin-duration ${rmon_session_15_min} bin-or-interval ${rmon_type} num-back ${num_back} num-show ${num_show}
    log    The PM result is ${res}
    ${output}     Should Match Regexp    ${res}    start-time\\s+\\d+-\\d+-\\d{2}T\\d+:(\\d+):
    log    the counter value is ${output}[1]
    ${clock_timer}   Convert To Integer    @{output}[1]
    ${rmon_session_minute}    Convert To Integer    ${rmon_session_minute}
    ${res1}    Evaluate    ${clock_timer} % ${rmon_session_minute}
    Should Be True    ${res1}==0    
    Log    Interval is locked to Time of Day.
    
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
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    log    Add pm task to pon port.
    Set Test Variable    ${pon_port}    ${pon_port}
    prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

case teardown
    [Documentation]
    [Arguments]
    log    teardown
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}     