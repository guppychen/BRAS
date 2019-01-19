*** Settings ***
Documentation     MVR shall support mapping one or more single tagged video VLAN to double tagged data service VLAN on all subscriber ports. Note that a double tagged VLAN may be transmitted out the subscriber port untagged. Use to be VID-R-282
Resource          ./base.robot


*** Variables ***
${add_ce_vlan}    ${p_match_vlan}

*** Test Cases ***
tc_MVR_support_mapping_untagged_video_to_double_tagged_data_service_VLAN_on_all_subscriber_ports
    [Documentation]    1	Configure a trunk port with all the MVR vlans	Trunk port with all vlans should be created	Use the command "show bridge table" to verify	
    ...    2	Configure STC port with 4 IGMP querier with the corresponding MVR vlans	Trunk port should become router port and in HAPPY state	Use the command "show igmp ports" and "show igmp domains"to verify	
    ...    3	Send multicast streams with the MVR muticast address range and associated vlan from the same STC port			
    ...    4	Configure a MVR profile that uses 4 vlans with different multicast address range	The profile is accepted		
    ...    5	Configure a matchlist profile to match untagged and ad a c-tag	Configuration is accepted		
    ...    6	Configure a service profile and service instance for the uni service	Configuration is accepted		
    ...    7	Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile	UNI service should be created		
    ...    8	Join the muticast group of all 4 vlans	Able to join the multicast group	Use wireshark and cature ithe IGMP joins make sure it has the correct vlan	
    ...    9	Configure a trunk port with the service vlan			
    ...    10	Send Bidirectional unicast traffic on the UNI port			
    ...    11	Using wireshark capture the packets on the trunk port with service vlan	Unicast traffic should be received with the service vlan and the added c-tag		
    ...    12	Using wireshark capture the packets on the uni port	Unicast traffic should be received untagged
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1442    @globalid=2321510    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a trunk port with all the MVR vlans Trunk port with all vlans(Done in init file)

    log    STEP:2 Configure STC port with 4 IGMP querier with the corresponding MVR vlans Trunk port should become router port and in HAPPY state Use the command "show igmp ports" and "show igmp domains"to verify
    log    create 4 double-tag IGMP quirier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]    ${add_ce_vlan}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}
    
    log    STEP:4 Configure a MVR profile that uses 4 vlans with different multicast address range The profile is accepted
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:5 Configure a matchlist profile to match untagged and ad a c-tag Configuration is accepted
    log    STEP:6 Configure a service profile and service instance for the uni service Configuration is accepted
    log    STEP:7 Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile UNI service should be created
    subscriber_point_add_svc    subscriber_point1    untagged    ${p_data_vlan}    cevlan_action=add-cevlan-tag    cevlan=${add_ce_vlan}    mcast_profile=${p_mcast_prf}

    log    STEP:3 Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    ${list_mc_grp_name}    add_multicast_group_to_igmp_host    tg1    igmp_host    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}
    Tg Save Config Into File    tg1    /tmp/${TEST NAME}.xml
    
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    log    get mcast_group and video_vlan Dictionary
    ${dict_group_vlan}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    add_mc_group_and_vlan_to_dict    ${dict_group_vlan}    @{p_mvr_network_list}[${index}]    ${p_igmp_group_session_num}    @{p_video_vlan_list}[${index}]
    
    log    check igmp multicast vlan for subscriber_point1
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}
    
    log    STEP:8 Join the muticast group of all 4 vlans Able to join the multicast group Use wireshark and cature ithe IGMP joins make sure it has the correct vlan
    stop_capture    tg1    service_p1
    ${save_file_mvr}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file_mvr}
    log    save captured packets to ${save_file_mvr}
    sleep    10s    Wait for save captured packets to ${save_file_mvr}
    log    analyze igmp packet
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    analyze_packet_count_greater_than    ${save_file_mvr}    ((igmp) && (igmp.version == 2) && (vlan.id == @{p_video_vlan_list}[${index}])) && (ip.dst == @{p_mvr_start_ip_list}[${index}])

    log    STEP:9 Configure a trunk port with the service vlan
    log    STEP:10 Send Bidirectional unicast traffic on the UNI port
    create_dhcp_server    tg1    dhcps    service_p1    ${p_dhcp_server.mac}    ${p_dhcp_server.ip}    ${p_dhcp_server.pool_start}    ${p_data_vlan}    ${add_ce_vlan}
    create_dhcp_client    tg1    dhcpc    subscriber_p1    dhcpc_group    ${p_dhcp_client.mac}
    start_capture    tg1    service_p1
    start_capture    tg1    subscriber_p1
    Tg Control Dhcp Server    tg1    dhcps    start
    Tg Control Dhcp Client    tg1    dhcpc_group    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${p_lease_negotiated_time}
    stop_capture    tg1    service_p1
    stop_capture    tg1    subscriber_p1

    log    STEP:11 Using wireshark capture the packets on the trunk port with service vlan Unicast traffic should be received with the service vlan and the added c-tag
    ${save_file_dhcp_us}    set variable    ${p_tg_store_file_path}/${TEST NAME}_dhcp_us.pcap
    ${filter_dhcp_us}    set variable    (bootp) && (vlan.id == ${p_data_vlan}) && (vlan.id == ${add_ce_vlan}) && (eth.src == ${p_dhcp_client.mac})
    run keyword and ignore error    save_and_analyze_packet_on_port    tg1    service_p1    ${filter_dhcp_us}    ${save_file_dhcp_us}

    log    STEP:12 Using wireshark capture the packets on the uni port Unicast traffic should be received untagged
    ${save_file_dhcp_ds}    set variable    ${p_tg_store_file_path}/${TEST NAME}_dhcp_ds.pcap
    ${filter_dhcp_ds}    set variable    (bootp) && (eth.type == 0x0800) && (eth.src == ${p_dhcp_server.mac})
    run keyword and ignore error    save_and_analyze_packet_on_port    tg1    subscriber_p1    ${filter_dhcp_ds}    ${save_file_dhcp_ds}

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    untagged    ${p_data_vlan}    cevlan=${add_ce_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    delete_tg_dhcp_session    tg1    dhcps    dhcpc    dhcpc_group