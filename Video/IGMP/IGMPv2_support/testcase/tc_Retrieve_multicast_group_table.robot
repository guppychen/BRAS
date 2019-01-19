*** Settings ***
Documentation     Calix NE must support retrieval via all management NBIs, the current set of joined Multicast groups, including by source with SSM.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Retrieve_multicast_group_table
    [Documentation]    Calix NE must support retrieval via all management NBIs, the current set of joined Multicast groups, including by source with SSM.
    [Tags]       @author=AnsonZhang     @TCID=AXOS_E72_PARENT-TC-1590    @globalid=2321664    @priority=P2    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:Calix NE must support retrieval via all management NBIs, the current set of joined Multicast groups, including by source with SSM.
    log    start the querier
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    start to capture the igmp at client
    start_capture    tg1    subscriber_p1
    start_capture    tg1    service_p1
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    log    STEP:Non-MVR Video with IGMP Proxy (Change Tag Match Single Tagged Subscriber Traffic): Add basic video service to two access interfaces. Perform the following tasks capturing traffic as the receive location for each task: Generate IGMP general queries from querier location, generate IGMP joins from each subscriber requesting unique stream per subscriber, generate requested multicast streams from querier, generate leave for each associated stream from each subscriber. -> The following traffic is received at the subscriber with the subscriber tag value: general IGMP queries, requested multicast streams, two last member group specific IGMP queries after the leave. Downstream IGMP traffic p-bit = 4. Downstream multicast stream traffic p-bit = p-bit received at uplink. The following single tagged with the changed-to-tag with p-bit = 4 traffic is received at the querier: joins/reports and leaves. No traffic is forwarded between the two lines.
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    general-query-interval=300    pbit-priority=4    last-member-query-count=2    last-member-query-interval=50
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
