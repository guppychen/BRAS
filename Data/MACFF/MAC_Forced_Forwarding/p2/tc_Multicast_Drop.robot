    
*** Settings ***
Documentation     Provision a mff service and a static snoop entry. From the provisioned host generate multicast traffic. -> No traffic is forwarded.
Resource          ./base.robot
Force Tags       @author=wchen    @feature=MACFF

*** Variables ***


*** Test Cases ***
tc_Multicast_Drop
    [Documentation]    Provision a mff service and a static snoop entry. From the provisioned host generate multicast traffic. -> No traffic is forwarded.
    [Tags]    @subFeature=MAC_Forced_Forwarding    @tcid=AXOS_E72_PARENT-TC-1419    @globalid=2286188    @priority=P2   @eut=NGPON2-4    @user_interface=CLI
    [Setup]      AXOS_E72_PARENT-TC-1419 setup
    [Teardown]   AXOS_E72_PARENT-TC-1419 teardown
    log    create traffic
    Tg Create Single Tagged Stream On Port    tg1    us    service_p1    subscriber_p1    vlan_id=${subscriber_vlan1}    vlan_user_priority=0
    ...    mac_src=${subscriber_mac1}    mac_dst=01:00:5e:0e:01:01    rate_mbps=1    frame_size=512    length_mode=fixed    l3_protocol=ipv4
    ...    ip_src_addr=${subscriber_ip1}    ip_dst_addr=225.14.1.1
    log    start traffic
    Tg Start All Traffic    tg1
    log    traffic running
    sleep    ${traffic_run_time2}
    log    stop traffic
    Tg Stop All Traffic    tg1
    log   analyze traffic result
    verify traffic stream all pkt loss    tg1    us


*** Keywords ***
AXOS_E72_PARENT-TC-1419 setup
    [Documentation]  setup
    [Arguments]
    log    setup
    log    create vlan
    prov_vlan    eutA    ${service_vlan1}    mff=ENABLED
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan1}
    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}    cevlan_action=remove-cevlan 
    log    create static host
    prov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}    ${subscriber_ip1}    gateway1 ${gateway_ip1} mac ${subscriber_mac1}
    
AXOS_E72_PARENT-TC-1419 teardown
    [Documentation]    teardown
    [Arguments]
    log    teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    log    remove static host
    dprov_ipv4_l2host_on_sub_port     eutA     subscriber_point1    ${service_vlan1}
    log    remove service
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan1}    ${service_vlan1}   
    log    service_point remove_svc and deprovision
    service_point_remove_vlan    service_point_list1    ${service_vlan1}
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan1}
