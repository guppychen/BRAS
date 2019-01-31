*** Settings ***
Documentation
Resource     ./base.robot
Force Tags     @feature=Ethernet Class Map      @author=MinGu

*** Variables ***

*** Test Cases ***
tc_Match_VLAN_with_multi_rules_add_s_tag
    [Documentation]
      
    ...    1	create a class-map with 16 rules to match 16 VLANs in flow 1	successfully		
    ...    2	create a policy-map to bind the class-map	successfully		
    ...    3	add eth-port1 to s-tag with transport-service-profile	successfully		
    ...    4	apply the s-tag and policy-map to the port of ethernet uni	successfully		
    ...    5	send 16 upstream traffic as the matching VLANs to uni port	eth-port1 can pass the upstream traffic with right tag.		
    ...    6	send 16 downstream traffic with double-tagged to eth-port1	client1 can receive the downstream traffic with 16 right c-tag.		

    
    [Tags]     @tcid=AXOS_E72_PARENT-TC-4348      @subFeature=10GE-12: Ethernet class map support      @globalid=2531535      @priority=P1      @eut=10GE-12          @user_interface=CLI    
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:5 send 16 upstream traffic as the matching VLANs to uni port
    log    STEP:6 send 16 downstream traffic with double-tagged to eth-port1
    : FOR    ${index}    IN RANGE    1    ${max_rule}+1
    \    ${class_map_match_multi_vlans}    evaluate    ${match_vlan_base}+${index}
    \    create_raw_traffic_udp    tg1    match_vlan_${index}_us    service_p1    subscriber_p1    ${class_map_match_multi_vlans}
    \    ...    mac_dst=${tg_server.mac}    mac_src=00:00:00:11:11:${index}    ip_dst=${tg_server.ip}    ip_src=10.1.67.${index}    rate_mbps=${pkt_rate}
    \    create_raw_traffic_udp    tg1    stag_vlan_${index}_ds    subscriber_p1    service_p1    ${service_vlan_1}    ${class_map_match_multi_vlans}
    \    ...    mac_dst=00:00:00:11:11:${index}    mac_src=${tg_server.mac}    ip_dst=10.1.67.${index}    ip_src=${tg_server.ip}    rate_mbps=${pkt_rate}
  
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
    
    ${save_file_service_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_service_p1.pcap
    ${save_file_subscriber_p1}    set variable    ${tg_store_file_path}/${TEST NAME}_subscriber_p1.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_service_p1}
    Tg Store Captured Packets   tg1    subscriber_p1    ${save_file_subscriber_p1}
    sleep    10s    Wait for save captured packets to ${save_file_service_p1} and ${save_file_subscriber_p1}
    
    : FOR    ${index}    IN RANGE    1    ${max_rule}+1
    \    ${class_map_match_multi_vlans}    evaluate    ${match_vlan_base}+${index}
    \    analyze_packet_count_greater_than    ${save_file_service_p1}
    \    ...    (vlan.id==${service_vlan_1}) && (vlan.id==${class_map_match_multi_vlans}) && (eth.src==00:00:00:11:11:${index}) && (eth.dst==${tg_server.mac}) && (ip.src == 10.1.67.${index}) && (ip.dst == ${tg_server.ip})
    \    analyze_packet_count_greater_than    ${save_file_subscriber_p1}
    \    ...    (vlan.id==${class_map_match_multi_vlans}) && (eth.src==${tg_server.mac}) && (eth.dst==00:00:00:11:11:${index}) && (ip.src == ${tg_server.ip}) && (ip.dst == 10.1.67.${index})
    
    

    
*** Keywords ***
case setup
    [Documentation]    setup
    log    STEP:1 create a class-map with 16 rules to match 16 VLANs in flow 1
    : FOR    ${index}    IN RANGE    1    ${max_rule}+1
    \    ${class_map_match_multi_vlans}    evaluate    ${match_vlan_base}+${index}
    \    prov_class_map    eutA    ${class_map}    ${class_map_type}    flow    ${flow_index}    ${index}    vlan=${class_map_match_multi_vlans}   
    
    log    STEP:2 create a policy-map to bind the class-map 
    prov_policy_map    eutA    ${policy_map}    class-map-ethernet    ${class_map}
    
    log    STEP:3 add eth-port1 to s-tag with transport-service-profile (done in suite_setup) 
    
    log    STEP:4 apply the s-tag and policy-map to the port of ethernet uni 
    subscriber_point_add_svc_user_defined    subscriber_point1     ${service_vlan_1}     ${policy_map}

case teardown
    [Documentation]    teardown
    log    teardown
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc_user_defined    subscriber_point1    ${service_vlan_1}     ${policy_map}    
    log    delete policy-map
    delete_config_object   eutA    policy-map    ${policy_map}
    log    delete class-map
    delete_config_object    eutA    class-map ethernet    ${class_map}
