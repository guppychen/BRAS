*** Settings ***
Documentation     Test suite verifies IGMP V2 and video traffic
Resource          ./base.robot

*** Variables ***
${igmp_version}    v2
${start_last_ip}    1

*** Test Cases ***
tc_igmp_v2_traffic
    [Documentation]       Test suite verifies IGMP V2 and video traffic
     ...    1.  Provision video service with proxy mode on system, send v2 GQ to uplink port, then send v2 report to ont-port join any group    video traffic flow fine with channel change works.
     ...    2.  show igmp router summary    the router is v2 mode
     ...    3.  show igmp ports summary    gpon port in igmp v2 mode
     ...    4.  show igmp hosts summary    gpon port in igmp v2 mode
     ...    5.  show igmp multicast summary    group on ont port and pon port is correct
     ...    6.  show igmp multicast group summary    group on gpon port is correct
    [Tags]    @feature=IGMP    @subfeature=IGMP Proxy    @author=CindyGao    @globalid=2276047    @tcid=AXOS_E72_PARENT-TC-531
    ...    @user_interface=CLI    @priority=P1    @eut=NGPON2-4
    [Teardown]   case teardown
    log    STEP:1 Provision video service with proxy mode on system, send v2 GQ to uplink port, then send v2 report to ont-port join any group, video traffic flow fine with channel change works.
    log    check point status
    service_point_list_check_status_up    service_point_list1
    subscriber_point_check_status_up    subscriber_point1 

    log    create igmp querier
    create_igmp_querier    tg1    igmp_querier    service_p1    ${igmp_version}    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}    ${p_igmp_querier.gateway}    ${p_video_vlan}
    tg control igmp querier by name    tg1    igmp_querier    start

    log    STEP:2 verify igmp router summary, the router is v2 mode
    service_point_check_igmp_routers    service_point1    ${p_video_vlan}    @{p_proxy.ip}[0]    ${p_igmp_querier.ip}    ${igmp_version}

    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    ${igmp_version}    ${p_igmp_host.mac}    ${p_igmp_host.ip}    ${p_igmp_querier.gateway}
    ...    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=${p_mcast_network}.${start_last_ip}
    tg control igmp    tg1    igmp_host    join

    log    STEP:3 verify igmp ports summary, gpon port in igmp v2 mode
    subscriber_point_check_igmp_ports    subscriber_point1    ${p_video_vlan}    ${igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}

    log    STEP:4 verify igmp hosts summary, gpon port in igmp v2 mode
    subscriber_point_check_igmp_hosts    subscriber_point1    ${p_video_vlan}    ${igmp_version}    @{p_proxy.ip}[0]    ${p_mcast_prf}

    log    STEP:5 verify igmp multicast summary, group on ont port and pon port is correct
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_summary    subscriber_point1    ${p_video_vlan}    ${p_mcast_network}.${last_ip}
    
    log    STEP:6 verify igmp multicast group summary
    log    check igmp multicast group
    : FOR    ${last_ip}    IN RANGE    ${start_last_ip}    ${start_last_ip}+${p_igmp_group_session_num}
    \    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_video_vlan}    ${p_mcast_network}.${last_ip}

*** Keywords ***
case teardown
    [Documentation]    case teardown
    log    delete tg session
    tg control igmp querier by name    tg1    igmp_querier    stop
    tg delete igmp querier    tg1    igmp_querier
    tg control igmp    tg1    igmp_host    leave
    tg delete igmp    tg1    igmp_host
    