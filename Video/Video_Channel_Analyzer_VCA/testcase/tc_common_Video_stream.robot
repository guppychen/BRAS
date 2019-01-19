*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_common_Video_stream
    [Documentation]    check it can works fine
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4599      @globalid=2533323      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: common video stream1, check it can works fine
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}   
    log    start vca join ip with not flow, start traffic,    
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
        
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    check vca parameter display correctly
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA    admin-state=Running    multicast-group=${vca_ip}    vlan=${service_vlan} 
    
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    
    log    prov port different vlan
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan2}
    
    log    STEP 2: common video stream2, check it can works fine
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream2    subscriber_p1    service_p1    ${service_vlan2}    &{tg_ds_param2}   
    cli    eutA    start vca join ip ${vca_ip2} vlan ${service_vlan2} duration ${dur_time}
        
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    check vca parameter display correctly
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA    admin-state=Running    multicast-group=${vca_ip2}    vlan=${service_vlan2} 
    
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
    prov_vlan    eutA    ${service_vlan}
    prov_vlan    eutA    ${service_vlan2}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    service_point remove_svc and deprovision
    cli    eutA    clear vca counters all
    Run Keyword And Ignore Error    service_point_remove_vlan    service_point_list1    ${service_vlan2}
    Run Keyword And Ignore Error    service_point_remove_vlan    service_point_list1    ${service_vlan}
    Run Keyword And Ignore Error   delete_config_object    eutA    vlan    ${service_vlan2}
    Run Keyword And Ignore Error   delete_config_object    eutA    vlan    ${service_vlan}
    Tg Delete All Traffic    tg1
    
  