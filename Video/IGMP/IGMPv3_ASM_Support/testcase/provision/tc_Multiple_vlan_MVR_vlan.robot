*** Settings ***
Documentation
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Multiple_vlan_MVR_vlan
    [Documentation]    1	Config all 4 MVR Vlan as IGMP version = 3.	system operation mode = V3
    ...    2	Config all 4 MVR Vlan as IGMP version = 2.	system operation mode = V2
    ...    3	config one vlan of 4 as IGMP version = 2; the other 3 vlan as v3	one vlan operation mode = V2 and other vlan operation mode = V3
    [Tags]       @author=philip_chen     @TCID=AXOS_E72_PARENT-TC-2249    @GlobalID=2346516
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1 Config all 8 MVR Vlan as IGMP version = 3. system operation mode = V3

    log    STEP:2 Config all 8 MVR Vlan as IGMP version = 2. system operation mode = V2

    log    STEP:3 config one vlan of 4 as IGMP version = 2; the other 7 vlan as v3 one vlan operation mode = V2 and other vlan operation mode = V3

    log    change all the mvr vlan to igmp version 2
    prov_igmp_profile    eutA    ${p_igmp_profile3}    V2

    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    check_igmp_host_summary    eutA    @{p_mvr_vlan_list}[${index}]    subscriber_point1    V2    @{p_proxy_1.ip}[0]

    log    change all the mvr vlan to igmp version 3
    prov_igmp_profile    eutA    ${p_igmp_profile3}    V3

    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    check_igmp_host_summary    eutA    @{p_mvr_vlan_list}[${index}]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

    log    change one of the mvr vlan to igmp version 2
    service_point_prov_igmp     service_point_list1    ${p_igmp_profile4}    ${p_proxy_1.intf_name}    ${p_proxy_1.ip}    ${p_proxy_1.mask}    ${p_proxy_1.gw}    @{p_mvr_vlan_list}[0]
    prov_igmp_profile    eutA    ${p_igmp_profile4}    V2

    check_igmp_host_summary    eutA    @{p_mvr_vlan_list}[0]    subscriber_point1    V2    @{p_proxy_1.ip}[0]
    : FOR    ${index}    IN RANGE    1    ${p_max_mvr_vlan_num}
    \    check_igmp_host_summary    eutA    @{p_mvr_vlan_list}[${index}]    subscriber_point1    V3    @{p_proxy_1.ip}[0]

*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2249 setup
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}
    service_point_prov    service_point_list1
    log    service_point_provision for uplink side

    log    create vlan
    : FOR    ${video_vlan}    IN    @{p_mvr_vlan_list}
    \    prov_vlan    eutA    ${video_vlan}

#    log    create transport-service-profile and add profile to uplink interface
#    service_point_add_vlan    service_point_list1    ${p_data_vlan},@{p_video_vlan_list}[0],@{p_video_vlan_list}[1],@{p_video_vlan_list}[2],@{p_video_vlan_list}[3],@{p_video_vlan_list}[4],@{p_video_vlan_list}[5],@{p_video_vlan_list}[6],@{p_video_vlan_list}[7]
    log    create igmp profile to vlan
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    service_point_prov_igmp     service_point_list1    ${p_igmp_profile3}    ${p_proxy_1.intf_name}    ${p_proxy_1.ip}    ${p_proxy_1.mask}    ${p_proxy_1.gw}    @{p_mvr_vlan_list}[${index}]

    log    subscriber side provision
    log    create mvr profile
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    prov_mvr_profile    eutA    ${p_mvr_prf3}    @{p_mvr_start_ip_list}[${index}]    @{p_mvr_end_ip_list}[${index}]    @{p_mvr_vlan_list}[${index}]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf3}    ${p_mvr_prf3}
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf3}

case teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-2249 teardown
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf3}
    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf3}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf3}
    log    remove vlan from restricted-ip-host
    : FOR    ${index}    IN RANGE    0    ${p_max_mvr_vlan_num}
    \    dprov_interface    eutA    restricted-ip-host    ${p_proxy_1.intf_name}    @{p_mvr_vlan_list}[${index}]
    log    delete mvr_vlan
    : FOR    ${video_vlan}    IN    @{p_mvr_vlan_list}
    \    delete_config_object    eutA    vlan    ${video_vlan}
    log    delete igmp-profile
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile3}
    delete_config_object    eutA    igmp-profile    ${p_igmp_profile4}
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}
