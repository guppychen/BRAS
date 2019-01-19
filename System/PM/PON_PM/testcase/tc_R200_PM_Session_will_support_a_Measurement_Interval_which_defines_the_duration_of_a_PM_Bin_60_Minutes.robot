*** Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM

*** Variables ***
${bin_count}    4
${all_or_current}    all

*** Test Cases ***
tc_R200_PM_Session_will _support_a_Measurement_Interval_which_defines_the_duration_of_a_PM_Bin: {60}_Minutes
    [Documentation]  Verify a measurement interval defined with Measurement Bin Duration of one hour.
    ...    Step 1: Provision a rmon-session of a one hour session on the PON interface.
    ...    Step 2: Check the running config to confirm the session is established.
    
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-754   @globalid=2307614    @eut=NGPON2-4    @priority=P1
    
    clear_pon_pm    eutA    ${pon_port}    ${rmon_type}    ${rmon_session_1_hour}     ${all_or_current}
    log    PM current bin has been cleared.
    verify_pon_pm_counters_all_cleared    eutA    ${pon_port}    ${rmon_session_1_hour}    ${rmon_type}    ${num_back}    ${num_show}    ${pon_pm_counter_name}

    Tg Create Untagged Stream On Port    tg1    raw_upstream1    p2    p1    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4
    ...    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    frame_size=512    length_mode=fixed     rate_mbps=${speed_M}
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p1    p2    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}   rate_mbps=${speed_M}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log     Step 2: send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    log    Keep sending traffic for a short period of time for the pm statis.   

    @{pon_pm_counter_value}    get_pon_pm_counter    eutA    ${pon_port}    ${rmon_session_1_hour}    ${rmon_type}    ${num_back}    ${num_show}    rx-unicast-pkts
    Should Not Be Equal    @{pon_pm_counter_value}[1]    0
    log    rx-unicast-pkts are being counted
    @{pon_pm_counter_value}    get_pon_pm_counter    eutA    ${pon_port}    ${rmon_session_1_hour}    ${rmon_type}    ${num_back}    ${num_show}    tx-unicast-pkts
    Should Not Be Equal    @{pon_pm_counter_value}[1]    0
    log    tx-unicast-pkts are being counted.

    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1

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
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_1_hour}    ${bin_count}

teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_1_hour}    ${bin_count}
