*** Settings ***
Documentation     Calix Video Service shall support provisioning of MVR configuration on a per subscriber port basis
Resource          ./base.robot

*** Variables ***
${sub_port2_type}    ${service_model.subscriber_point2.attribute.interface_type}
${sub_port2_name}    ${service_model.subscriber_point2.name}
${non_mvr_mcast_prf}    mcast_prf_non_mvr

*** Test Cases ***
tc_Layer3_Applications_Video_MVR_per_subscriber
    [Documentation]    1	Configure a trunk port with all the MVR vlans	Trunk port with all vlans	
    ...    2	Configure STC port with 4 IGMP querier with the corresponding MVR vlans	Trunk port should become router port and in HAPPY state	Use the command "show igmp ports" and "show igmp domains"to verify	
    ...    3	Send multicast streams with the MVR muticast address range and associated vlan from the same STC port			
    ...    4	Configure an MVR profile that uses 4 vlans with different multicast address range	The profile is accepted		
    ...    5	Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile to 2 uni port	UNI service should be created		
    ...    6	Join the muticast group of all 4 vlans on both ports	Able to join the multicast group	Use wireshark and cature ithe IGMP joins make sure it has the correct vlan	
    ...    7	Configure another subscriber withour the MVR profile	Configuration successful		
    ...    8	Send a multicast stream out of the MVR range			
    ...    9	Join the out of range multicast channel on the 3rd port	Subscriber should be able to join		
    ...    10	Remove service from all the uni port	Remove operation should be successful
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1444    @globalid=2321512    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a trunk port with all the MVR vlans Trunk port with all vlans (Done in init file)
    set test variable    ${reconfig_flag}    False

    log    STEP:2 Configure STC port with 4 IGMP querier with the corresponding MVR vlans Trunk port should become router port and in HAPPY state Use the command "show igmp ports" and "show igmp domains"to verify
    log    create IGMP querier with the corresponding MVR vlans
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    create_igmp_querier    tg1    igmp_querier${index}    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    @{p_video_vlan_list}[${index}]
    \    tg control igmp querier by name    tg1    igmp_querier${index}    start
    \    service_point_check_igmp_routers    service_point1    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    STEP:3 Send multicast streams with the MVR muticast address range and associated vlan from the same STC port
    log    create igmp host for subscriber_point1
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_multicast_group_to_igmp_host    tg1    igmp_host1    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}    mc_grp_prefix=mc_grp_sub1
    
    log    create igmp host for subscriber_point2
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    add_multicast_group_to_igmp_host    tg1    igmp_host2    ${p_max_mvr_vlan_num}    ${p_igmp_group_session_num}    ${p_mvr_start_ip_list}    mc_grp_prefix=mc_grp_sub2

    log    STEP:4 Configure an MVR profile that uses 4 vlans with different multicast address range The profile is accepted
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_video_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    STEP:5 Configure UNI service with a vlan other than the MVR vlans and apply the mvr and mcast profile to 2 uni port UNI service should be created
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    STEP:6 Join the muticast group of all 4 vlans on both ports Able to join the multicast group Use wireshark and cature ithe IGMP joins make sure it has the correct vlan
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    log    get mcast_group and video_vlan Dictionary
    ${dict_group_vlan}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    add_mc_group_and_vlan_to_dict    ${dict_group_vlan}    @{p_mvr_network_list}[${index}]    ${p_igmp_group_session_num}    @{p_video_vlan_list}[${index}]
    
    log    check igmp multicast vlan for subscriber_point
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point2    ${p_data_vlan}    &{dict_group_vlan}

    log    capture IGMP reports upstream and make sure IGMP reports are tagged with the MVR vlan IGMP reports are tagged with MVR vlan
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    10s
    log    verify report packet
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    analyze_igmp_report_packet_for_mc_session    ${save_file}    @{p_video_vlan_list}[${index}]    @{p_proxy.ip}[0]    @{p_mvr_network_list}[${index}]    ${p_igmp_group_session_num}

    log    STEP:7 Configure another subscriber withour the MVR profile Configuration successful (use subscriber_point2 as equipment limitation)
    log    configure non_mvr service on subscriber_point2
    tg control igmp    tg1    igmp_host2    leave
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    set test variable    ${reconfig_flag}    True
    prov_multicast_profile    eutA    ${non_mvr_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    @{p_video_vlan_list}[0]    cevlan_action=remove-cevlan    mcast_profile=${non_mvr_mcast_prf}   cfg_prefix=sub2

    log    STEP:8 Send a multicast stream out of the MVR range
    create_igmp_host    tg1    igmp_host3    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=1    mc_group_name=mc_group3    mc_group_start_ip=${p_new_mc_ip} 

    log    STEP:9 Join the out of range multicast channel on the 3rd port Subscriber should be able to join
    create_igmp_querier    tg1    igmp_querier_add    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_data_vlan}
    tg control igmp querier by name    tg1    igmp_querier_add    start
    tg control igmp    tg1    igmp_host3    join
    subscriber_point_check_igmp_multicast_summary    subscriber_point2    @{p_video_vlan_list}[0]    ${p_new_mc_ip}

    log    STEP:10 Remove service from all the uni port Remove operation should be successful(see case teardown part)

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    Run Keyword If    'True'=='${reconfig_flag}'    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    @{p_video_vlan_list}[0]    mcast_profile=${non_mvr_mcast_prf}   cfg_prefix=sub2
    ...    ELSE    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    delete_config_object    eutA    multicast-profile    ${non_mvr_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    tg control igmp querier by name    tg1    igmp_querier${index}    stop
    \    tg delete igmp querier    tg1    igmp_querier${index}
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    tg control igmp    tg1    igmp_host3    leave
    tg delete igmp    tg1    igmp_host3

