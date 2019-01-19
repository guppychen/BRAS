*** Settings ***
Documentation     1	Configure a subscriber to receive video service. Ensure that fast leave is disabled	Subscriber is able to watch video, change channels
...    2	Send a leave	The channel should still be in the snooping table until a groups specific query is sent and timed out
Resource          ./base.robot


*** Variables ***
${group_session_num}    1
${wait_last_member_query_timeout}    10s

*** Test Cases ***
tc_Layer3_Applications_Video_Immediate_Leave_disabled
    [Documentation]    1	Configure a subscriber to receive video service. Ensure that fast leave is disabled	Subscriber is able to watch video, change channels
    ...    2	Send a leave	The channel should still be in the snooping table until a groups specific query is sent and timed out
    [Tags]       @author=AnsonZhang     @TCID=AXOS_E72_PARENT-TC-1556    @globalid=2321630    @priority=P2    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure a subscriber to receive video service. Ensure that fast leave is disabled Subscriber is able to watch video, change channels
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:Verify video is working and channel changes working.
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]

    log    STEP:2 Send a leave The channel should still be in the snooping table until a groups specific query is sent and timed out
    tg control igmp    tg1    igmp_host    leave
    sleep    ${wait_last_member_query_timeout}
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    sleep    ${wait_last_member_query_timeout}
    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]    no

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}    general-query-interval=300    last-member-query-count=5    last-member-query-interval=50
    log    prov multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}
    log    prov igmp profile for vlan
    igmp_prov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    config igmp proxy interface
    igmp_prov_proxy    eutA    ${p_proxy.intf_name}    ${p_proxy.ip[0]}    ${p_proxy.mask}    ${p_proxy.gw}    ${p_data_vlan}
    log    prov video service
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    cevlan_action=remove-cevlan    mcast_profile=${p_mcast_prf}
    log    create igmp host
    create_igmp_host    tg1    igmp_host    subscriber_p1    v2    ${p_igmp_host.mac}    ${p_igmp_host.ip}
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}

case teardown
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
