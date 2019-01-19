*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_vcahost_showing_up_correctly
    [Documentation]    check it can works fine
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4575      @globalid=2533299      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI       
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan2}    &{tg_ds_param1}   
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan2} duration ${dur_time}    
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    STEP 1: vcahost showing up correctly
    log    check vcahost parameter showing up correctly
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA 
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_group_summary    eutA    ${vca_ip}    ${service_vlan2}    ${igmp_param.interface} 
    Wait Until Keyword Succeeds    2min    5s    check_igmp_hosts_summary    eutA    ${service_vlan2}    ${igmp_param.interface}    version=${igmp_param.version}    
    ...    src_ip=${ip_src_addr}   mgmt_status=${igmp_param.mgmt_status}    oper_state=${igmp_param.oper_state}    querier_status=${igmp_param.querier_status}
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    clear vca counter before send traffic
    cli    eutA    clear vca counters all
    log    prov vlan with type n:1, service_point add svc
    prov_vlan    eutA    ${service_vlan2}
    log    prov vca source ip address ${ip_src_addr} vlan ${service_vlan2}
    service_point_add_vlan    service_point_list1    ${service_vlan2}
    igmp_prov_proxy    eutA    ${restricted_ip_host}    ${ip_src_addr}     ${proxy_mask}    ${ip_src_gate}    ${service_vlan2}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    service_point remove_svc and deprovision
    cli    eutA    clear vca counters all
    service_point_remove_vlan    service_point_list1    ${service_vlan2}
    delete_config_object    eutA    vlan    ${service_vlan2}
    Tg Delete All Traffic    tg1
