*** Settings ***
Documentation     contour case description
Resource          ./base.robot
Force Tags        @feature=PON_PM    @subfeature=PON_PM
*** Variables ***
${bin_count}    1440
${all_or_current}    current
${log_category}    GENERAL



*** Test Cases ***
tc_OLT_EXA_device_must_support_the_ability_to_clear_the_PM_Session_Current_Bins
    [Documentation]    A user with the appropriate permissions must be able to clear the current PM Session - this operation MUST be recorded. We need topersistentlyrecord who did the enable/disable operation - this needs to be reportable on the mgmt plane (EWI, CLI, NetConf) in association with the PM Session.
    ...    Step 1: Provision a rmon-session on the PON interface.
    ...    Step 2: Send unicast L2 traffic. 
    ...    Step 3: Stop the L2 traffic.
    ...    Step 4: Check PM counter to verify the unicast counter is correct.
    ...    Step 5: Clear the current PM counter of unicast.
    ...    Step 6: Check PM counter to verify the unicast counter is cleared.
    ...    Step 7: Check the clear operation has been recorded by syslog.
    
    [Setup]    setup
    [Teardown]    teardown
    [Tags]    @author=JerryWu    @tcid=AXOS_E72_PARENT-TC-764   @globalid=2307624    @eut=NGPON2-4    @priority=P1

    clear_pon_pm    eutA    ${pon_port}    ${rmon_type}    ${rmon_session_15_min}     ${all_or_current}
    verify_pon_pm_counters_all_cleared    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}    ${num_show}    ${pon_pm_counter_name}
    log    PM current bin has been cleared.
    
    Tg Create Untagged Stream On Port    tg1    raw_upstream1    p2    p1    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4
    ...    ip_src_addr=${ip1}    ip_dst_addr=${ip2}    frame_size=512    length_mode=fixed    rate_mbps=${speed_M}

    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    p1    p2    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${mac2}    mac_dst=${mac1}
    ...    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}   rate_mbps=${speed_M}
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    log     Step 2: send traffic,wait ${send_traffic_time}s.
    sleep    ${send_traffic_time}
    log    Keep sending traffic for a short period of time for the pm statis.   

    @{pon_pm_counter_value}    get_pon_pm_counter    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}    ${num_show}    rx-unicast-pkts
    Should Not Be Equal    @{pon_pm_counter_value}[1]    0
    log    rx-unicast-pkts are being counted
    @{pon_pm_counter_value}    get_pon_pm_counter    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}    ${num_show}    tx-unicast-pkts
    Should Not Be Equal    @{pon_pm_counter_value}[1]    0
    log    tx-unicast-pkts are being counted.
 
    Tg Stop All Traffic    tg1
    log     Step 3: stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    
    clear_pon_pm    eutA    ${pon_port}    ${rmon_type}    ${rmon_session_15_min}     ${all_or_current}
    verify_pon_pm_counters_all_cleared    eutA    ${pon_port}    ${rmon_session_15_min}    ${rmon_type}    ${num_back}    ${num_show}    ${pon_pm_counter_name}
    log    PM current bin has been cleared.        
    tg save config into file    tg1    /tmp/pm.xml

    Tg Verify Traffic Loss For Stream Is Within         tg1    raw_upstream1    0.01
    Tg Verify Traffic Loss For Stream Is Within         tg1    raw_downstream1    0.01

    ${log_event}    show_last_log_event    eutA    ${log_category}
    Should Contain    ${log_event}    pon-rmon-pmdata-cleared   
    
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
     prov_pon_pm    eutA     ${pon_port}    ${rmon_session_15_min}    ${bin_count}

teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1      ${match_vlan}     ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    dprov_pon_pm    eutA    ${pon_port}    ${rmon_session_15_min}    ${bin_count}