*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_show_igmp_check_all_parameters_correctly
    [Documentation]    check it can works fine  
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4574      @globalid=2533298      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI     
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}   
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    STEP 1: show igmp, check igmp all parameters correctly
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA 
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_group_summary    eutA    ${vca_ip}    ${service_vlan}    ${igmp_param.interface} 
    Wait Until Keyword Succeeds    2min    5s    check_igmp_multicast_sum    eutA    ${service_vlan}     ${igmp_param.interface}    (\\d+)    (\\d+)    ${vca_ip}    ${service_vlan}
    Wait Until Keyword Succeeds    2min    5s    check_igmp_hosts_summary    eutA    ${service_vlan}    ${igmp_param.interface}   
    Wait Until Keyword Succeeds    2min    5s    check_igmp_ports_summary    eutA    ${service_vlan}    ${igmp_param.interface}
    
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
    log    prov vlan, service_point add svc
    prov_vlan    eutA    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    service_point remove_svc and deprovision
    cli    eutA    clear vca counters all
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
    Tg Delete All Traffic    tg1
    