*** Settings ***
Documentation     Modify Stream Limit Increase: Add basic video service to the access interface using any stream limit value. Proxy IGMP mode in use. Actively join the limit +1 streams. Modify the limit to increase by 1. Join an additional stream to actively join + 1 the new limit. Continue to increase limit several additional times. -> The streams are limited to the provisioned limit increasing as the limit increases. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
Resource          ./base.robot

*** Variables ***
${max_streams_min}    2
${max_streams_max}    3
${group_session}    4

*** Test Cases ***
tc_Modify_Stream_Limit_Increase
    [Documentation]    Modify Stream Limit Increase: Add basic video service to the access interface using any stream limit value. Proxy IGMP mode in use. Actively join the limit +1 streams. Modify the limit to increase by 1. Join an additional stream to actively join + 1 the new limit. Continue to increase limit several additional times. -> The streams are limited to the provisioned limit increasing as the limit increases. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    [Tags]    @subfeature=IGMPv2 support    @TCID=AXOS_E72_PARENT-TC-1642    @globalid=2321717    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]    case setup
    log    STEP:Modify Stream Limit Increase: Add basic video service to the access interface using any stream limit value. Proxy IGMP mode in use. Actively join the limit +1 streams. Modify the limit to increase by 1. Join an additional stream to actively join + 1 the new limit. Continue to increase limit several additional times. -> The streams are limited to the provisioned limit increasing as the limit increases. Note: As another way to verify the service bandwidth requirement implementation differences between GPON and DSL GPON scripts should provision bw-profile < total multicast bandwidth required and DSL scripts should be provisioned with => total multicast bandwidth required.
    log    modify the max streams of multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${max_streams_min}
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    log    start the igmp host to join
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_min}
    log    leave the groups
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    log    modify the max-stream
    prov_multicast_profile    eutA    ${p_mcast_prf}    max-streams=${max_streams_max}
    tg control igmp    tg1    igmp_host    join
    Wait Until Keyword Succeeds    1min    10sec    check current groups    eutA    ${max_streams_max}
    tg control igmp    tg1    igmp_host    leave
    Wait Until Keyword Succeeds    1min    10sec    subscriber_point_check_igmp_multicast_group    subscriber_point1    ${p_data_vlan}    @{p_groups_list}[0]
    ...    no
    [Teardown]    case teardown

*** Keywords ***
case setup
    log    create the igmp profile
    prov_igmp_profile    eutA    ${p_igmp_prf}    ${p_igmp_version[0]}
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
    ...    ${p_igmp_host.gateway}    ${p_match_vlan}    session=${group_session}    mc_group_start_ip=@{p_groups_list}[0]
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
