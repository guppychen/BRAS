*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_check_vca_with_not_configured_VLAN
    [Documentation]    check vca with not configured VLAN, no process crashed
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4603      @globalid=2533327      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: check vca with not configured VLAN
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan}    &{tg_ds_param1}   
    log    start vca join ip with not configured vlan, start traffic,    
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan2} duration ${dur_time}
    
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    STEP 2: show vca, vca can showing up properly 
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA    pkts_num=none    multicast-group=${vca_ip}    rx-packets=0    vlan=${service_vlan2}
    cli    eutA    stop vca now

    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    cli    eutA    stop vca now
    
    
    
*** Keywords ***
case_setup
    [Documentation]
    [Arguments]
    log    case setup
    log    clear vca, interface counter before send traffic
    cli    eutA    clear vca counters all
    log    prov vlan, service_point add svc
    prov_vlan    eutA    ${service_vlan}
    log    prov vca source ip address ${ip_src_addr} vlan ${service_vlan}
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    clear vca, interface counter before send traffic
    cli    eutA    clear vca counters all
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan}
    Tg Delete All Traffic    tg1