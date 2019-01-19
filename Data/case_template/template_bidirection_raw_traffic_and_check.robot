*** Settings ***
Documentation    test_suite keyword lib
Resource          ../base.robot

*** Variable ***

*** Keywords ***
template_bidirection_raw_traffic_and_check
    [Arguments]    ${tg_us_param}    ${tg_ds_param}    ${us_traffic_filter}    ${ds_traffic_filter}    ${traffic_loss_rate}
    ...    ${traffic_run_time}=10s    ${stc_wait_time}=5s    ${packet_store_path}=/tmp
    ...    ${service_point_list}=${EMPTY}    ${subscriber_point}=${EMPTY}
    [Documentation]    create bidirection raw traffic, send traffic and check packet loss, analyze packet with filter
    ...    Please use tg1, service port with service_p1, subscriber port with subscriber_p1
    ...    
    ...    Arguments:
    ...    | =Argument Name= | \ =Argument Value= \ |
    ...    | tg_us_param | upstream traffic parameter for create_raw_traffic_udp, use dictionary format as param_key=param_value |
    ...    | tg_ds_param | downstream traffic parameter for create_raw_traffic_udp, use dictionary format as param_key=param_value |
    ...    | us_traffic_filter | wireshark filter for packet captured on service_p1 |
    ...    | ds_traffic_filter | wireshark filter for packet captured on subscriber_p1 |
    ...    | traffic_loss_rate | acceptable traffic loss rate |
    ...    | traffic_run_time | traffic run time, default=10s |
    ...    | stc_wait_time | traffic wait time, default=5s |
    ...    | packet_store_path | packet store path, default=/tmp |
    ...    | service_point_list | service_point_list in service_model.yaml |
    ...    | subscriber_point | subscriber_point in service_model.yaml |
    ...    Example:
    ...    Please create &{tg_us_param} and &{tg_ds_param} in test case *** Variable *** part,
    ...    then using ${tg_us_param} and ${tg_ds_param} format for case template
    ...    please refer to Milan/ST_Test_Cases/Data/VLAN/Ethernet_class_map_support/testcase/tc_Match_untagged_add_s-tag.robot
    [Tags]       @author=CindyGao
    [Teardown]   traffic_teardown
    log    create upstream traffic
    create_raw_traffic_udp    tg1    upstream    service_p1    subscriber_p1    &{tg_us_param}
    log    create downstream traffic
    create_raw_traffic_udp    tg1    downstream    subscriber_p1    service_p1    &{tg_ds_param}

    log    send traffic and capture
    Tg Clear Traffic Stats    tg1
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}    Wait for traffic run     
    Tg Stop All Traffic    tg1
    sleep    ${stc_wait_time}    wait for stc stop
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}
    
    log    save packet
    ${save_file_service_p1}    set variable    ${packet_store_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${packet_store_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    sleep    10s    Wait for save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}
    
    log    analyze upstream packet
    analyze_packet_count_greater_than    ${save_file_service_p1}    ${us_traffic_filter}
    log    analyze downstream packet
    analyze_packet_count_greater_than    ${save_file_subscriber_p1}    ${ds_traffic_filter}
 
 
*** Keywords *** 
traffic_teardown
    [Documentation]    teardown
    Run Keyword And Ignore Error    stop_capture    tg1    service_p1
    Run Keyword And Ignore Error    stop_capture    tg1    subscriber_p1
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
