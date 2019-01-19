*** Settings ***
Documentation    Displaying show igmp multicast commands
Resource     ./base.robot

*** Variables ***
${mvr_vlan}    @{p_video_vlan_list}[0]

*** Test Cases ***
tc_Layer3_Applications_Video_show_igmp_multicast_commands
    [Documentation]
    ...    1	Configure Video Service on UNI port	Configuration successful		
    ...    2	Configure STC port with IGMP quirier and send multicast streams	Configuration successful		
    ...    3	Join multicast groups from the provisioned subscribers	Verify that subscriber able to receive multicast stream		
    ...    4	Issue the command "show igmp multicast group ip "	Verify correct output is displayed		
    ...    5	Issue the command "show igmp multicast interface ethernet "	Verify correct output is displayed		
    ...    6	Issue the command "show igmp multicast summary"	Verify correct output is displayed		
    ...    7	Issue the command "show igmp multicast vlan "	Verify correct output is displayed		
    [Tags]     @tcid=AXOS_E72_PARENT-TC-3484      @subFeature=MVR support      @globalid=2478939      @priority=P2    @user_interface=CLI    @eut=NGPON2-4
    [Setup]     case setup
    [Teardown]     case teardown
      
    log    STEP:1 Configure Video Service on UNI port Configuration successful 
    prov_mvr_profile    eutA    ${p_mvr_prf}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    ${mvr_vlan}
    prov_multicast_profile    eutA    ${p_mcast_prf}    ${p_mvr_prf}    ${p_mcast_max_stream}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}

    log    STEP:2 Configure STC port with IGMP quirier and send multicast streams Configuration successful 
    create_igmp_querier    tg1    igmp_querier    service_p1    ${p_igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${mvr_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    service_point_check_igmp_routers    service_point1    ${mvr_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}

    log    STEP:3 Join multicast groups from the provisioned subscribers Verify that subscriber able to receive multicast stream 
    create_igmp_host    tg1    igmp_host1    subscriber_p1    ${p_igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]  
    tg control igmp    tg1    igmp_host1    join

    log    STEP:4 Issue the command "show igmp multicast group ip " Verify correct output is displayed 
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1
    \    ...    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}    summary=no

    log    check command "show igmp multicast group summary " Verify correct output is displayed 
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1
    \    ...    ${mvr_vlan}    @{p_mvr_network_list}[0].${last_ip}

    log    STEP:5 Issue the command "show igmp multicast interface ethernet " Verify correct output is displayed (NOT SUPPORT YET)

    log    STEP:6 Issue the command "show igmp multicast summary" Verify correct output is displayed
    : FOR    ${last_ip}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_data_vlan}    @{p_mvr_network_list}[0].${last_ip}    ${mvr_vlan}

    log    STEP:7 Issue the command "show igmp multicast vlan " Verify correct output is displayed
    ${dict_group_vlan}    Create Dictionary    &{EMPTY}
    : FOR    ${index}    IN RANGE    1    ${p_igmp_group_session_num}+1
    \    Set To Dictionary    ${dict_group_vlan}    @{p_mvr_network_list}[0].${index}=${mvr_vlan}
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_vlan    subscriber_point1    ${p_data_vlan}    &{dict_group_vlan}

    
*** Keywords ***
case setup
    [Documentation]    case setup
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1

case teardown
    [Documentation]    case teardown
    log    case teardown: subscriber side deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf}
    
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1