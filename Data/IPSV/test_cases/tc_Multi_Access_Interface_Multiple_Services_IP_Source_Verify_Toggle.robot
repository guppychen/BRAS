*** Settings ***
Documentation     Multi Access Interface, Multiple Services, IP Source Verify Toggle:  Provision IP Source Verify enabled on a unique service on two access interface. For each interface generate subscriber-to-network matching and non-matching UDP traffic for each service (IP Source does not match).   Toggle IP Source Verify on one of the interfaces service. Re-generate traffic.  Toggle IP Source Verify again.  Re-generate traffic.   -> Only traffic matching static entries is forwarded when IPSV is enabled.  When IPSV is disabled traffic without a matching entry is forwarded for only that service with IPSV disabled.  The behavior of the service without IPSV toggle remains unchanged.
...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Multi_Access_Interface_Multiple_Services_IP_Source_Verify_Toggle
    [Documentation]    Multi Access Interface, Multiple Services, IP Source Verify Toggle:  Provision IP Source Verify enabled on a unique service on two access interface. For each interface generate subscriber-to-network matching and non-matching UDP traffic for each service (IP Source does not match).   Toggle IP Source Verify on one of the interfaces service. Re-generate traffic.  Toggle IP Source Verify again.  Re-generate traffic.   -> Only traffic matching static entries is forwarded when IPSV is enabled.  When IPSV is disabled traffic without a matching entry is forwarded for only that service with IPSV disabled.  The behavior of the service without IPSV toggle remains unchanged.
    ...    SR Security Feature Interaction Config #7: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Enabled
    ...    SR Security Feature Interaction Config #5: Static, DHCP Snoop Disabled, MACFF Enabled, IPSV Disabled
    [Tags]       @TCID=AXOS_E72_PARENT-TC-568    @GlobalID=2286115    @EUT=NGPON2-4
    [Setup]      setup
    log    create 2 streams on each device, one untagged use native vlan. one match and one not, the one match alawys pass 100%, and not matched one only passed 100% shen ipsv disabled, and 100 loss when ipsv enabled.
    create_raw_traffic_udp    tg1    matchip_up1    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${service_mac1}    mac_src=${client_mac1}    ip_dst=${gateway1}    ip_src=${client_ip1}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_up1    service_p1    subscriber_p1    ovlan=${subscriber_vlan}    mac_dst=${dmac}    mac_src=${smac}    ip_dst=${dip}    ip_src=${sip}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    matchip_up2    service_p1    subscriber_p1    ovlan=${native_vlan}    mac_dst=${service_mac2}    mac_src=${client_mac2}    ip_dst=${gateway2}    ip_src=${client_ip2}    rate_mbps=${rate_mbps1}
    create_raw_traffic_udp    tg1    notmatchip_up2    service_p1    subscriber_p1    ovlan=${native_vlan}    mac_dst=${dserver_mac}    mac_src=${dclient_mac}    ip_dst=${dserver_ip}    ip_src=${dclient_ip}    rate_mbps=${rate_mbps1}
    tg save config into file    tg1        /tmp/ipsv2.xml
    Tg Start All Traffic    tg1
    sleep    10
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up1     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up2     ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up1
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up2
    log    disable ipsv on vlan1, vlan1 streams all passed, and vlan2 only pass matched one
    prov_vlan    eutA    ${service_vlan}    source-verify=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up1     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up2     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within     tg1    notmatchip_up1     ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up2
    log    disable ipsv on vlan 2, as vlan1 ipsv has been disabled before, 2 vlans' streams all passed
    prov_vlan    eutA    ${service_vlan2}    source-verify=disabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1     ${loss_rate}
    log    disable ipsv on vlan2, enable ipsv on vlan1, all vlan2 streams passed, and vlan1 only pass matched stream
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    5
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up1     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within     tg1    matchip_up2     ${loss_rate}
    Tg Verify Traffic Loss For Stream Is Within     tg1    notmatchip_up2     ${loss_rate}
    verify_traffic_stream_all_pkt_loss    tg1    notmatchip_up1
    [Teardown]   teardown



*** Keywords ***
setup
    log    create 2 service vlans with ipsv enabled
    prov_vlan    eutA    ${service_vlan}    source-verify=enabled
    prov_vlan    eutA    ${service_vlan2}    source-verify=enabled
    log    add 2 vlans to uplink port
    service_point_add_vlan    service_point_list1    ${service_vlan},${service_vlan2}
    log    add service to each sub device, one with change tag, and another add 2 tags
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan
    subscriber_point_add_svc    subscriber_point2    untagged    ${service_vlan2}    ctag_action=add-cevlan-tag    cvlan=${subscriber_vlan2}    cfg_prefix=ipsv
    log    create ipv4 l2host on each device
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}    ${client_ip1}    gateway1 ${gateway1} mac ${client_mac1}
    prov_ipv4_l2host_on_sub_port    eutA    subscriber_point2    ${service_vlan2}    ${client_ip2}    gateway1 ${gateway2} mac ${client_mac2}

teardown
    log    delete all streams
    Tg Delete All Traffic    tg1
    log    delete all ipv4 l2host on sub-port
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point1    ${service_vlan}
    dprov_ipv4_l2host_on_sub_port    eutA    subscriber_point2    ${service_vlan2}
    log    remove eth-svc on sub-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_remove_svc    subscriber_point2    untagged    ${service_vlan2}    cvlan=${subscriber_vlan2}    cfg_prefix=ipsv
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan},${service_vlan2}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    delete_config_object    eutA    vlan    ${service_vlan2}
