*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***


*** Test Cases ***
tc_reload_system
    [Documentation]    check it can works fine
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4596      @globalid=2533320      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: reload system successfully
    reload    eutA
    
    log    prov vlan, service_point add svc
    prov_vlan    eutA    ${service_vlan2}
    log    prov vca source ip address ${ip_src_addr} vlan ${service_vlan2}
    cli    eutA    configure
    cli    eutA    cli show-defaults enable
    cli    eutA    end
    service_point_prov    service_point_list1
    service_point_add_vlan    service_point_list1    ${service_vlan2}
   
    log    STEP 2: show vca correctly
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan2}    &{tg_ds_param1}
    log    start vca join ip with not flow, start traffic,    
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan2} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    check vca parameter display correctly
    Wait Until Keyword Succeeds    2min    5s    check_vca_rx_packets    eutA    admin-state=Running    multicast-group=${vca_ip}    vlan=${service_vlan2}
    
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
    
case_teardown
    [Documentation]
    [Arguments]
    log    case teardown
    log    clear vca, interface counter before send traffic
    cli    eutA    clear vca counters all
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan2}
    delete_config_object    eutA    vlan    ${service_vlan2}
    Tg Delete All Traffic    tg1
