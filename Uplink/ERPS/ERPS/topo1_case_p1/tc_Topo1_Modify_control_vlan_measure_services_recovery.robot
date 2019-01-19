*** Settings ***
Documentation     1.Configure an ERPS ring with three nodes
...    2.Configure data service
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo1_Modify_control_vlan_measure_services_recovery-
    [Documentation]    1	Modify control-vlan of erps-ring	service recover
    [Tags]       @tcid=AXOS_E72_PARENT-TC-1317    @globalid=2319067    @subfeature=ERPS    @priority=P1    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    prov_erps_ring    ${service_model.${erps_node}.device}     ${service_model.${erps_node}.name}    control-vlan=${changed_vlan}

    log    STEP:1 Modify control-vlan of erps-ring service recover
    wait until keyword succeeds    2 min    5 sec    check_erps_ring_up    eutA    6


    log  check service recover
    Tg Create single Tagged Stream On Port    tg1    raw_upstream1    service_p1    subscriber_p1    vlan_id=${subscriber_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed
    ...    mac_src=${smac}    mac_dst=${dmac}     rate_pps=${rate_pps}    l3_protocol=ipv4    ip_src_addr=${sip}    ip_dst_addr=${dip}    l4_protocol=udp    udp_dst_port=64    udp_src_port=63
    ...    mac_src_count=400    mac_src_mode=increment
    Tg Create single Tagged Stream On Port    tg1    raw_downstream1    subscriber_p1      service_p1    vlan_id=${service_vlan}    vlan_user_priority=0    frame_size=512    length_mode=fixed    mac_src=${dmac}    mac_dst=${smac}
    ...    l3_protocol=ipv4    ip_src_addr=${dip}    ip_dst_addr=${sip}    l4_protocol=udp    rate_pps=${rate_pps}    mac_src_count=400    mac_src_mode=increment

    Tg Start All Traffic     tg1
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1

    sleep    5
    cli      eutA     show bridge table
    cli      eutB     show bridge table
    cli      eutC     show bridge table

    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    TG Verify Traffic Loss For Stream Is Within    tg1    raw_upstream1    ${ERPS_max_second_for_switch}





*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes

    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}
    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}

    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


teardown
    [Documentation]
    [Arguments]
    log    Enter teardown
    Tg Save Config Into File    tg1     /tmp/erps_case1.xml
    sleep    33

    log    remove service on ont-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}

    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}

    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
