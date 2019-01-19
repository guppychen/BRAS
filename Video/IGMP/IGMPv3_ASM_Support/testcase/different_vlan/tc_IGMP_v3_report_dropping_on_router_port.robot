*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_IGMP_v3_report_dropping_on_router_port
    [Documentation]    1	system uplink is inni role let system learn the interface as mrouter first then send igmp v3 report to the interface.	IGMP v3 report has been discard by the mrouter interface and did not show in MC table
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2275    @GlobalID=2346542
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 system uplink is inni role let system learn the interface as mrouter first then send igmp v3 report to the interface. IGMP v3 report has been discard by the mrouter interface and did not show in MC table

    log    case setup: subscriber side provision
    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start

    log    check igmp querier on uplink eth device
    service_point_check_igmp_routers    ${uplink_eth_point}    @{p_video_vlan_list}[0]    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}    V3
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1

    clear_igmp_statistics    eutA    vlan    @{p_video_vlan_list}[0]
    create_igmp_host    tg1    igmp_host1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    ...    session=${p_igmp_group_session_num}    mc_group_start_ip=@{p_mvr_start_ip_list}[0]
    tg control igmp    tg1    igmp_host1    join
    sleep    ${wait_igmp_client_join_leave}

    log    check igmp multicast group on subscriber connected device
    check_igmp_multicast_group_not_contain    eutA    @{p_mvr_start_ip_list}[0]     @{p_video_vlan_list}[0]    ${service_model.service_point1.member.interface1}
    ${result}    show_igmp_statistics_vlan    eutA    @{p_video_vlan_list}[0]
    should match regexp    ${result}    rx-pkts\\s+2

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2275 setup


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2275 teardown
    tg control igmp    tg1    igmp_host1    leave
    tg delete igmp    tg1    igmp_host1
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}