*** Settings ***
Documentation     tc_Ethernet_Statistics_from_65_to_127_bytes_Packets
Resource          ./base.robot
Force Tags        @feature=ONT_Ethernet_Port_PM    @subfeature=ONT_PM_rmon_session

*** Variables ***


*** Test Cases ***
tc_Ethernet_Statistics_from_65_to_127_bytes_Packets
    [Documentation]    tc_Ethernet_Statistics_from_65_to_127_bytes_Packets
    ...    Step 1:Provision all ethernet ports on ONT for Data Services. 
    ...           The provisioning should take place.
    ...    Step 2:With Traffic generator provide traffic to the port to exercise the associated counter 'etherStatsHighCapacityPkts65to127Octets' (frames between 65 and 127 bytes).
    ...           Expect the associated counter to increment.
    
    [Setup]    Case_Test_Setup
    [Teardown]    Case_Test_Teardown
    [Tags]    @author=Meiqin_Wang    @tcid=AXOS_E72_PARENT-TC-182    @globalid=2224510    @eut=NGPON2-4    @priority=P3
    log    check point status
    clear_interface_counters    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    
    Tg Create Untagged Stream On Port    tg1    upstream1    p1    p2    mac_src=${mac1}    mac_dst=${mac2}    l3_protocol=ipv4    ip_src_addr=${ip1}
    ...                                  ip_dst_addr=${ip2}    frame_size=100    length_mode=fixed    rate_pps=1000
    Tg Create single Tagged Stream On Port    tg1    downstream1    p2    p1    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=100    length_mode=fixed
    ...                                       rate_pps=1000    mac_src=${mac2}    mac_dst=${mac1}    l3_protocol=ipv4    ip_src_addr=${ip2}    ip_dst_addr=${ip1}
    
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    tg save config into file   tg1   /tmp/${TEST NAME}.xml
    log     send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1 
    log     stop traffic,wait ${stop_traffic_time}s
    sleep    ${stop_traffic_time}
    
    Tg Verify Traffic Loss For Stream Is Within         tg1    upstream1    ${lost_rate}
    Tg Verify Traffic Loss For Stream Is Within         tg1    downstream1    ${lost_rate}
    
    ${tx_total_pkts}    get_traffic_stream_stats    tg1    upstream1    tx    total_pkts
    
    ${ont_pm_counter}    check_interface_ont_pm    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}
    ...                                                    ${duration}    ${rmon_type}    ${num_back}    ${num_show}    upstream-packets-65-to-127-octets

    log      compare send traffics = ont_pm
    Should Be Equal    ${tx_total_pkts}    ${ont_pm_counter}
    
    log    Succeed

*** Keyword ***
Case_Test_Setup
    [Documentation]    test case setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${match_vlan}    ${service_vlan}

    Set Test Variable    ${service_model.subscriber_point1.name}    
    log    add service to subscriber port
    prov_interface_rmon_session    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}    ${duration}    ${count}    
    
Case_Test_Teardown
    [Documentation]    test case teardown
    log    deprovision other configuration in test step
    Run Keyword And Ignore Error    Tg Stop All Traffic    tg1
    Run Keyword And Ignore Error    Tg Delete All Traffic    tg1
    
    log    delete service to subscriber port
    dprov_interface_rmon_session    eutA    ${service_model.subscriber_point1.attribute.interface_type}    ${service_model.subscriber_point1.name}    ${duration}    ${count}   
    
    log    subscriber_point remove_svc and deprovision
    subscriber_point_remove_svc    subscriber_point1    ${match_vlan}    ${service_vlan} 
    
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    
    

