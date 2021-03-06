*** Settings ***
Documentation
Resource     ./base.robot

*** Variables ***
${bandwidth}    20
&{tg_ds_param}    mac_dst=${tg_ds_param1.mac_dst}    mac_src=${tg_ds_param1.mac_src}    ip_dst=${tg_ds_param1.ip_dst}    ip_src=${tg_ds_param1.ip_src}


*** Test Cases ***
tc_high_quality_Video_stream
    [Documentation]    check it can works fine
    [Tags]     @author=YUE SUN    @tcid=AXOS_E72_PARENT-TC-4600      @globalid=2533324      @priority=P2      @eut=NGPON2-4    @eut=GPON-8r2    @eut=10GE-12    @eut=GE-24r2          @user_interface=CLI    
    [Setup]     case_setup
    [Teardown]     case_teardown
    
    log    STEP 1: set high quality video stream
    log    set downstream traffic
    create_raw_traffic_udp    tg1    stream1    subscriber_p1    service_p1    ${service_vlan}    rate_mbps=${bandwidth}    &{tg_ds_param}
    log    start vca join ip with not flow, start traffic,    
    cli    eutA    start vca join ip ${vca_ip} vlan ${service_vlan} duration ${dur_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run 
    
    log    STEP 2: show vca, vca can showing up properly 
    ${res}    check_vca_rx_packets    eutA    admin-state=Running    multicast-group=${vca_ip}    vlan=${service_vlan}
    ${match}    ${rate_mbps_max}    should Match Regexp    ${res}    rate-mbps-max\\s+(\\d+)
    should be true    1<${rate_mbps_max}<=${bandwidth}
    
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