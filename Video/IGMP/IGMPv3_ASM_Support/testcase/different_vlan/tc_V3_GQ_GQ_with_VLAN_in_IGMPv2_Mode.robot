*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_V3_GQ_GQ_with_VLAN_in_IGMPv2_Mode
    [Documentation]    1	send V3 GQ to uplink	no mrouter can be created
    ...    2	Show vlan igmp mode	the pon and ont port under igmp v2 mode
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2289    @GlobalID=2346556
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 send V3 GQ to uplink no mrouter can be created

    log    STEP:2 Show vlan igmp mode the pon and ont port under igmp v2 mode

    log    check igmp host version after set igmp version in igmp profile
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]
    log    case setup: subscriber side provision
    set test variable    ${uplink_eth_point}    @{service_model.service_point_list1}[0]
    create_igmp_querier    tg1    igmp_querier1    service_p1    v3    ${p_igmp_querier1.mac}    ${p_igmp_querier1.ip}    ${p_igmp_querier1.gateway}    @{p_video_vlan_list}[0]
    tg control igmp querier by name    tg1    igmp_querier1    start

    log    check igmp querier on uplink eth device
    check_igmp_routers_sumarry_not_contain    eutA    @{p_video_vlan_list}[0]    ${service_model.service_point1.member.interface1}    V3    @{p_proxy_1.ip}[0]    ${p_igmp_querier1.ip}
    check_igmp_host_summary    eutA    @{p_video_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]




*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2289 setup
    prov_igmp_profile    eutA    ${p_igmp_profile1}    V2


case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2289 teardown
    tg control igmp querier by name    tg1    igmp_querier1    stop
    tg delete igmp querier    tg1    igmp_querier1
    prov_igmp_profile    eutA    ${p_igmp_profile1}    auto
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    sleep    ${wait_uplink_port_up}