*** Settings ***
Documentation     1	Configure the EUT for multicast traffic. This will involve setting host and router ports.	Multicast is able to be received. A STB can join and leave channels
...    2	Use a traffic generator to send a join to a router interface	The join is ignored, tx-report count should not increment. No further action is taken by the EUT
...    3	Use a traffic generator to send a leave to a router interface	The leave is ignored, tx-leave counter should not increment. No further action is taken by the EUt
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Layer3_Aplications_Video_Dropping_packets_correctly
    [Documentation]    1	Configure the EUT for multicast traffic. This will involve setting host and router ports.	Multicast is able to be received. A STB can join and leave channels
    ...    2	Use a traffic generator to send a join to a router interface	The join is ignored, tx-report count should not increment. No further action is taken by the EUT
    ...    3	Use a traffic generator to send a leave to a router interface	The leave is ignored, tx-leave counter should not increment. No further action is taken by the EUt
    [Tags]       @author=AnsonZhang     @TCID=AXOS_E72_PARENT-TC-1585    @globalid=2321659    @priority=P1    @eut=NGPON2-4    @eut=GPON-8r2
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Configure the EUT for multicast traffic. This will involve setting host and router ports. Multicast is able to be received. A STB can join and leave channels
    tg control igmp querier by name    tg1    igmp_querier    start
    Wait Until Keyword Succeeds    1min    10sec    service_point_check_igmp_routers    service_point1    ${p_data_vlan}    @{p_proxy.ip}[0]
    ...    ${p_igmp_querier.ip}
    clear_igmp_statistics    eutA    all
    log    STEP:2 Use a traffic generator to send a join to a router interface The join is ignored, tx-report count should not increment. No further action is taken by the EUT
    Tg Create Single Tagged Stream On Port    tg1    report    subscriber_p1    service_p1    vlan_id=${p_data_vlan}    mac_src=${p_igmp_querier.mac}
    ...    vlan_user_priority=4    mac_dst=@{p_groups_mac_list}[0]    l3_protocol=ipv4    ip_src_addr=${p_igmp_querier.ip}    ip_dst_addr=@{p_groups_list}[0]    l4_protocol=igmp
    ...    igmp_version=2    igmp_type=16    igmp_msg_type=report    igmp_group_addr=@{p_groups_list}[0]    igmp_multicast_addr=@{p_groups_list}[0]    length_mode=fixed    frame_size=250
    ...    transmit_mode=single_burst

    log    STEP:3 Use a traffic generator to send a leave to a router interface The leave is ignored, tx-leave counter should not increment. No further action is taken by the EUt
    Tg Create Single Tagged Stream On Port    tg1    leave    subscriber_p1    service_p1    vlan_id=${p_data_vlan}    mac_src=${p_igmp_querier.mac}
    ...    vlan_user_priority=4    mac_dst=@{p_groups_mac_list}[0]    l3_protocol=ipv4    ip_src_addr=${p_igmp_querier.ip}    ip_dst_addr=@{p_groups_list}[0]    l4_protocol=igmp
    ...    igmp_version=2    igmp_type=17    igmp_msg_type=report    igmp_group_addr=@{p_groups_list}[0]    igmp_multicast_addr=@{p_groups_list}[0]    length_mode=fixed    frame_size=250
    ...    transmit_mode=single_burst

    Tg Start All Traffic    tg1
    sleep    10s
    Tg Stop All Traffic    tg1

    ${num_leave}    get_igmp_statistics    eutA    option=rx-leaves
    ${num_report}    get_igmp_statistics    eutA    option=rx-reports

    Should Be true    0==${num_leave}
    Should Be true    0==${num_report}

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
