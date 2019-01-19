*** Settings ***
Documentation     Initialization file test suites
...               It is for putting suite level setup and teardown procedures
...               And setting the forced tags for all the test cases in folder and subfolder
Suite Setup       IGMPV3_ASM_suite_provision
Suite Teardown    IGMPV3_ASM_deprovision
Force Tags        @feature=IGMP    @subfeature=IGMPV3_ASM    @author=Philip_Chen      @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***
${mvr_vlan_num}    4

*** Keywords ***
IGMPV3_ASM_suite_provision
    [Documentation]    suite provision for sub_feature
    # add by llin for AT-3568
    log   set cli show-default enable
    cli   eutA   configure
    cli   eutA   cli show-default enable
    cli   eutA   end
    # add by llin for AT-3568

    log    suite provision for sub_feature
    service_point_prov    service_point_list1
    log    service_point_provision for uplink side

    log    create vlan
    prov_vlan    eutA    ${p_data_vlan}
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    prov_vlan    eutA    ${video_vlan}

    log    create transport-service-profile and add profile to uplink interface
    service_point_add_vlan    service_point_list1    ${p_data_vlan},@{p_video_vlan_list}[0],@{p_video_vlan_list}[1]
    log    create igmp profile to vlan
    service_point_prov_igmp     service_point_list1    ${p_igmp_profile1}    ${p_proxy_1.intf_name}    ${p_proxy_1.ip}    ${p_proxy_1.mask}    ${p_proxy_1.gw}    @{p_video_vlan_list}[0]
    service_point_prov_igmp     service_point_list1    ${p_igmp_profile2}    ${p_proxy_2.intf_name}    ${p_proxy_2.ip}    ${p_proxy_2.mask}    ${p_proxy_2.gw}    @{p_video_vlan_list}[1]

    log    subscriber side provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_prov    subscriber_point2
    subscriber_point_prov    subscriber_point3
    log    create mvr profile
    prov_mvr_profile    eutA    ${p_mvr_prf1}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[0]
    prov_mvr_profile    eutA    ${p_mvr_prf2}    @{p_mvr_start_ip_list}[0]    @{p_mvr_end_ip_list}[0]    @{p_video_vlan_list}[1]
    log    create multicast profile
    prov_multicast_profile    eutA    ${p_mcast_prf1}    ${p_mvr_prf1}
    prov_multicast_profile    eutA    ${p_mcast_prf2}    ${p_mvr_prf2}
    log    subscriber_point_add_svc with multicast profile
    subscriber_point_add_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}
    subscriber_point_add_svc    subscriber_point2    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}    cfg_prefix=auto2
    subscriber_point_add_svc    subscriber_point3    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}    cfg_prefix=auto3
IGMPV3_ASM_deprovision
    [Documentation]    suite deprovision for sub_feature
    log    suite deprovision for sub_feature
    log    subscriber_point deprovision
    subscriber_point_remove_svc    subscriber_point1    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}
    subscriber_point_remove_svc    subscriber_point2    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}    cfg_prefix=auto2
    subscriber_point_remove_svc    subscriber_point3    ${p_match_vlan_ont}    ${p_data_vlan}    mcast_profile=${p_mcast_prf1}    cfg_prefix=auto3

    log    delete multicast profile
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf1}
    delete_config_object    eutA    multicast-profile    ${p_mcast_prf2}
    log    delete mvr profile
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf1}
    delete_config_object    eutA    mvr-profile    ${p_mvr_prf2}
    log    uplink side deprovision
    service_point_dprov_igmp    service_point_list1    ${p_igmp_profile1}    ${p_proxy_1.intf_name}    @{p_video_vlan_list}[0]
    service_point_dprov_igmp    service_point_list1    ${p_igmp_profile2}    ${p_proxy_2.intf_name}    @{p_video_vlan_list}[1]
    service_point_remove_vlan   service_point_list1    ${p_data_vlan},@{p_video_vlan_list}[0],@{p_video_vlan_list}[1]
    service_point_dprov    service_point_list1
    delete_config_object    eutA    vlan    ${p_data_vlan}
    : FOR    ${video_vlan}    IN    @{p_video_vlan_list}
    \    delete_config_object    eutA    vlan    ${video_vlan}
    subscriber_point_dprov    subscriber_point1
    subscriber_point_dprov    subscriber_point2
    subscriber_point_dprov    subscriber_point3

    # add by llin for AT-3568
    log   set cli show-default enable
    cli   eutA      configure
    cli   eutA      cli show-default disable
    cli   eutA      end
    # add by llin for AT-3568
    Application Restart Check   eutA
