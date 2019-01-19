*** Settings ***
Documentation     Test suite rerieve multicast forwarding table 
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${start_last_ip}    1

*** Test Cases ***
tc_rerieve_multicast_forwarding_table
    [Documentation]       Test suite rerieve multicast forwarding table 
    ...    1	send igmp query to uplink interface	retrieve multicast router interface successfully		
    ...    2	send igmp join message from downlink host to join a group	successful		
    ...    3	retrieve the multicast group	successful		
    ...    4	provision static multicast route interface	successful		
    ...    5	send igmp join message from downlink host to join another group	successful		
    ...    6	retrieve the multicast group	successful
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276064    @tcid=AXOS_E72_PARENT-TC-548
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Teardown]   case teardown
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1 
    
    log    STEP:1 send igmp query to uplink interface retrieve multicast router interface successfully
    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start
    log    verify igmp router summary
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

    log    STEP:2 send igmp join message from downlink host to join a group successful
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=${p_mcast_network}.${start_last_ip}
    tg control igmp    tg1    igmp_host    join

    log    STEP:3 retrieve the multicast group successful
    log    check igmp multicast group
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_network}.${last_ip}

    log    STEP:4 provision static multicast route interface successful(NOT support static multicast route interface now)

    log    STEP:5 send igmp join message from downlink host to join another group successful
    create_igmp_host    tg1    igmp_host2    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=${p_mcast_network2}.${start_last_ip}
    tg control igmp    tg1    igmp_host2    join

    log    STEP:6 retrieve the multicast group successful
    log    check igmp multicast group
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_network2}.${last_ip}

*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    tg control igmp    tg1    igmp_host2    leave
    tg delete igmp    tg1    igmp_host2
    