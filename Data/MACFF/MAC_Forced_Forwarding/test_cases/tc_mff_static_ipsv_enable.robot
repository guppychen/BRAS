*** Settings ***
Documentation     Provision mff enabled, IP Source Verify enabled, with a static entry. Generate upstream UDP traffic. -> All traffic is forwarded.
Resource          ./base.robot
Force Tags    @feature=MACFF    @author=wchen

*** Variables ***


*** Test Cases ***
tc_mff_static_ipsv_enable
    [Documentation]    Provision mff enabled, IP Source Verify enabled, with a static entry. Generate upstream UDP traffic. -> All traffic is forwarded.
    [Tags]    @tcid=AXOS_E72_PARENT-TC-1395   @subFeature=MAC_Forced_Forwarding    @globalid=2286164    @priority=P1   @eut=NGPON2-4
    [Setup]      AXOS_E72_PARENT-TC-1395 setup
    [Teardown]   AXOS_E72_PARENT-TC-1395 teardown
    log    STEP:Provision mff enabled, IP Source Verify enabled, with a static entry. Generate upstream UDP traffic. -> All traffic is forwarded.

    # add by llin for AT-3139 2017.10.9
    log    show L3 host
    wait_mff_dynamic_host_table       eutA       ${service_model.service_point2.member.interface1}
    # add by llin for AT-3139 2017.10.9
    log    create traffic
    Tg Create Single Tagged Stream On Port    tg1    us    subscriber_p1    subscriber_p1    vlan_id=${subscriber_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=${gateway_mac1}    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip1}    ip_dst_addr=${subscriber_ip2}    l4_protocol=udp    udp_dst_port=6400   udp_src_port=6300    
    log   start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   sleep 3 second and verify traffic pass
    sleep  3
    TG Verify Traffic Loss For Stream Is Within    tg1    us    ${loss_rate}
    
*** Keywords ***
AXOS_E72_PARENT-TC-1395 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED    source-verify=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto1
    subscriber_point_add_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cevlan_action=remove-cevlan    cfg_prefix=auto2
    log    create static hosts
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} mac ${subscriber_mac1}
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}    ${subscriber_ip2}    gateway1 ${gateway_ip1} mac ${subscriber_mac2}

AXOS_E72_PARENT-TC-1395 teardown
    [Documentation]  teardown
    [Arguments]
    log    teardown
    Tg Save Config Into File    tg1     /tmp/MFF_2286164.xml
    sleep    33
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static hosts
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point2    ${service_vlan1}
    log    remove services
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    ${subscriber_vlan2}    ${service_vlan1}    cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
