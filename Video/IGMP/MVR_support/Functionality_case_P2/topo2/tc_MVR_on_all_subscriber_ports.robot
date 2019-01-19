*** Settings ***
Documentation     Calix Video Service shall support Multicast VLAN Registration on all subscriber ports
Resource          ./base.robot


*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Layer3_Applications_Video_MVR_on_all_subscriber_ports
    [Documentation]    1	Configure a trunk port with MVR vlan
    ...    2	Configure STC port to be a IGMP querier and attach it to the trunk port and send multicast streams	Trunk port should become a router port upon receiving IGMP queries	Use the command "show igmp ports" to verify	
    ...    3	Configure MVR profile and apply it to at least two subscriber port	Ports are configured with the MVR profile	MVR configuration takes. You can confirm with "show running-config interface ethernet gx" command	
    ...    4	Send IGMP Joins for the channels within the MVR range	Able to Join the multicast stream	Use the command "show igmp multicast" to verify	
    ...    5	Capture IGMP reports upstream and make sure IGMP reports are tagged with the MVR vlan	IGMP reports are tagged with MVR vlan	
    [Tags]       @author=CindyGao     @TCID=AXOS_E72_PARENT-TC-1440    @globalid=2321508    @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a trunk port with MVR vlan (Done in init file)

    log    STEP:2 Configure STC port to be a IGMP querier and attach it to the trunk port and send multicast streams Trunk port should become a router port upon receiving IGMP queries Use the command "show igmp ports" to verify
    log    create IGMP quirier with the corresponding MVR vlans
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${p_igmp_version}
    
    log    STEP:3 Configure MVR profile and apply it to at least two subscriber port Ports are configured with the MVR profile MVR configuration takes. You can confirm with "show running-config interface ethernet gx" command
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2
    
    log    STEP:4 Send IGMP Joins for the channels within the MVR range Able to Join the multicast stream Use the command "show igmp multicast" to verify
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host1    join
    tg control igmp    tg1    igmp_host2    join
    log    check igmp multicast summary for subscriber_point1
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1
    \    ...    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}
    
    log    check igmp multicast summary for subscriber_point2
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point2
    \    ...    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}

    log    STEP:5 Capture IGMP reports upstream and make sure IGMP reports are tagged with the MVR vlan IGMP reports are tagged with MVR vlan
    stop_capture    tg1    service_p1
    ${save_file}    set variable    ${p_tg_store_file_path}/${TEST NAME}.pcap
    Tg Store Captured Packets   tg1    service_p1    ${save_file}
    log    save captured packets to ${save_file}
    sleep    10s
    log    verify report packet
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    analyze_packet_count_greater_than    ${save_file}
    \    ...    ((igmp.type == ${igmpv2_type_report}) && (vlan.id == ${mvr_vlan}) && (ip.src == @{p_proxy.ip}[0]) && (ip.dst == @{p_mvr_network_list}[0].${last_ip}))

*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1   
    subscriber_point_check_status_up    subscriber_point2
    
    log    mvr provision
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}

    log    create igmp host
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_name=mc_group1    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${p_igmp_version}    ${p_igmp_host2.mac}    ${p_igmp_host2.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan_sub2}    session=${p_igmp_group_session_num}    mc_group_name=mc_group2    mc_group_start_ip=@{p_mvr_start_ip_list}[0]    

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_sub2}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}   cfg_prefix=sub2

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
