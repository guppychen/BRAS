*** Settings ***
Documentation     DHCP with IP Source Verify Toggle: Provision IP Source Verify and DHCP Snooping enabled. Force a client to obtain a DHCP address. Generate UDP (500 byte frames) traffic in each direction. Toggle IP Source Verify to disabled. Re-generate traffic. Toggle IP Source Verify to enabled. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic is forwarded within 11% of the transmitted rate.
...
...    SR Security Feature Interaction Config #12: DHCP, DHCP Snoop Enabled, MACFF Disabled, IPSV Enabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_DHCP_with_IP_Source_Verify_Toggle
    [Documentation]    DHCP with IP Source Verify Toggle: Provision IP Source Verify and DHCP Snooping enabled. Force a client to obtain a DHCP address. Generate UDP (500 byte frames) traffic in each direction. Toggle IP Source Verify to disabled. Re-generate traffic. Toggle IP Source Verify to enabled. Re-generate traffic. -> When IP Source Verify is disabled or enabled all traffic is forwarded within 11% of the transmitted rate.
    ...
    ...    SR Security Feature Interaction Config #12: DHCP, DHCP Snoop Enabled, MACFF Disabled, IPSV Enabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-563    @GlobalID=2286110    @EUT=NGPON2-4
    [Setup]      setup
    log    create dhcp server and client, can see 2 dhcp leases
    create_dhcp_server    tg1    dserver    service_p1    ${dserver_mac}    ${dserver_ip}    ${dclient_ip}    ${service_vlan}
    create_dhcp_client    tg1    dclient    subscriber_p1    dcg    ${dclient_mac}    ${subscriber_vlan}    session=2
    Tg Control Dhcp Server    tg1    dserver    start
    Tg Control Dhcp Client    tg1    dcg    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    log    show dhcp leases, 2
    check_l3_hosts    eutA    2    ${service_vlan}    ${service_model.subscriber_point1.name}
    log    create bi-directional bound traffic and not match traffic, only matched upstream and all downstream can pass, not matched downstream loss 100%
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dserver    dcg    ${rate_mbps1}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    dcg    dserver    ${rate_mbps2}
    create_raw_traffic_udp    tg1    notmatchip_up    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_down    subscriber_p1    service_p1    ovlan=${service_vlan}    mac_dst=${smac}    mac_src=${dmac}    ip_dst=${sip}    ip_src=${dip}    rate_mbps=${rate_mbps1}
    @{pass_str}    create list  dhcp_upstream    dhcp_downstream    notmatchip_down
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    log    disable ipsv, all streams no loss
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    log    enable ipsv again, only matched upstream and all down streams pass
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    :FOR    ${str}    IN    @{pass_str}
    \    Tg Verify Traffic Loss For Stream Is Within      tg1    ${str}      ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up
    [Teardown]   teardown




*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-563 setup
    log    create dhcp-profile
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    log    create vlan
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}    source-verify=enabled
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding	ENABLED
    prov_vlan_egress    eutA    ${service_vlan}    unknown-unicast-flooding	ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan

teardown
    [Documentation]
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-563 teardown
    Tg Control Dhcp Client    tg1    dcg    stop
    Tg Control Dhcp Server    tg1    dserver    stop
    Tg Delete Dhcp Client    tg1    dclient
    Tg Delete Dhcp Server    tg1    dserver
    Tg Delete All Traffic    tg1
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    l2-dhcp-profile    ${dhcp_profile_name}