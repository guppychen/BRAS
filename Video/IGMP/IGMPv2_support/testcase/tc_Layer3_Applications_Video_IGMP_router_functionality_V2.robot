*** Settings ***
Documentation     1 Configure an uni port with video service and apply the multicast profile Video service should be created on the UNI. Port will be configured as a HOST (IGMP Querier for the DS devices) Issue the command "show igmp ports" and show igmp hosts" to verify    #    Action    Expected Result    Notes
...               2 Configure a trunk port with video vlans Trunk port created
...               3 Configure IGMP querier on STC and send multicast streams through the trunk port using the appropriate vlans STC configured as IGMP querier and send multicast streams
...               4 Configure several video igmpv2 subscriber on STC and send joins from each subscriber to the uni port Video is delivered
...               5 Issue the show commands "show igmp multicast ethernet g14" to verify correct channels are joined Port is aware of all channels
...               6 Keep the channel up for few minutes and monitor the port using wireshark
...               7 Verify that the port is queried at the interval specified in the IGMP profile. Subscriber should response to the received query and keep the channel up Verify IGMP reports are correctly sent Issue the command "show running-config profile igmp-profile | detail" to view the query interval settings.
...               8 Leave a channel Port is updated with correct information Use the show igmp multicast ethernet gX to verify
Resource          ./base.robot

*** Variables ***
${timer_for_query_from_proxy}    70s

*** Test Cases ***
tc_Layer3_Applications_Video_IGMP_router_functionality_V2
    [Documentation]    1 Configure an uni port with video service and apply the multicast profile Video service should be created on the UNI. Port will be configured as a HOST (IGMP Querier for the DS devices) Issue the command "show igmp ports" and show igmp hosts" to verify    #    Action    Expected Result    Notes
    ...    2 Configure a trunk port with video vlans Trunk port created
    ...    3 Configure IGMP querier on STC and send multicast streams through the trunk port using the appropriate vlans STC configured as IGMP querier and send multicast streams
    ...    4 Configure several video igmpv2 subscriber on STC and send joins from each subscriber to the uni port Video is delivered
    ...    5 Issue the show commands "show igmp multicast ethernet g14" to verify correct channels are joined Port is aware of all channels
    ...    6 Keep the channel up for few minutes and monitor the port using wireshark
    ...    7 Verify that the port is queried at the interval specified in the IGMP profile. Subscriber should response to the received query and keep the channel up Verify IGMP reports are correctly sent Issue the command "show running-config profile igmp-profile | detail" to view the query interval settings.
    ...    8 Leave a channel Port is updated with correct information Use the show igmp multicast ethernet gX to verify
    [Tags]    @subfeature=IGMPv2 support    @tcid=AXOS_E72_PARENT-TC-1547    @globalid=2321621    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:1 Configure an uni port with video service and apply the multicast profile Video service should be created on the UNI. Port will be configured as a HOST (IGMP Querier for the DS devices) Issue the command "show igmp ports" and show igmp hosts" to verify
    log    STEP:2 Configure a trunk port with video vlans Trunk port created
    log    STEP:3 Configure IGMP querier on STC and send multicast streams through the trunk port using the appropriate vlans STC configured as IGMP querier and send multicast streams
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    STEP:4 Configure several video igmpv2 subscriber on STC and send joins from each subscriber to the uni port Video is delivered
    tg control igmp    tg1    igmp_host    join
    log    STEP:5 Issue the show commands "show igmp multicast ethernet g14" to verify correct channels are joined Port is aware of all channels
    log    Show the snooping table. This would be a list of all the channels currently joined on the EUT
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:6 Keep the channel up for few minutes and monitor the port using wireshark
    start_capture    tg1    subscriber_p1
    Comment    wait for 70s to capture the query packet
    sleep    ${timer_for_query_from_proxy}
    stop_capture    tg1    subscriber_p1
    log    STEP:7 Verify that the port is queried at the interval specified in the IGMP profile. Subscriber should response to the received query and keep the channel up Verify IGMP reports are correctly sent Issue the command "show running-config profile igmp-profile | detail" to view the query interval settings.
    ${query_num}    save_and_analyze_packet_on_port    tg1    subscriber_p1    igmp.type == 0x11
    Should Be True    ${query_num}>=2
    log    STEP:8 Leave a channel Port is updated with correct information Use the show igmp multicast ethernet gX to verify
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile with query interval 30s
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}    general-query-interval=300
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
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_groups_list}[0]
    log    create query with query interval 60s
    create_igmp_querier    tg1    igmp_querier    service_p1    v2    ${p_igmp_querier.mac}    ${p_igmp_querier.ip}
    ...    ${p_igmp_querier.gateway}    ${p_data_vlan}    query_interval=60

case teardown
    log    remove the service
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan}    ${p_data_vlan}    mcast_profile=${p_mcast_prf}
    log    delete the igmp proxy
    delete_config_object    eutA    interface restricted-ip-host    ${p_proxy.intf_name}
    log    no igmp profile from vlan
    igmp_dprov_vlan_igmp_profile    eutA    ${p_igmp_prf}    ${p_data_vlan}
    log    delete mcast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf}
