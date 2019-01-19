*** Settings ***
Documentation     1.Configure two ERPS rings with three nodes
...    2.Configure data service through erps ring
Resource          ./base.robot
Force Tags        @feature=ERPS    @author=BlairWang

*** Variables ***
*** Test Cases ***
tc_Topo2_run_DHCPv4_traffic_do_erps_switch_measure_switch_time_and_service_recover
    [Documentation]    1	run data services	can get DHCP lease, dhcp bounded traffic is Ok
    ...    2	disable forwarding interface on master node, then enable it	check packet loss
    [Tags]        @tcid=AXOS_E72_PARENT-TC-1279    @globalid=2319029    @subfeature=ERPS    @priority=P2    @eut=NGPON2-4    @eut=GPON8-R2
    [Setup]       setup
    [Teardown]    teardown
    log    STEP:1 run data services can get DHCP lease, dhcp bounded traffic is Ok
    create_dhcp_server    tg1    dhcps_stag    service_p1    ${server_mac}    ${server_ip}    ${pool_ip_start}    ${service_vlan}    lease_time=100
    create_dhcp_client    tg1    dhcpc_stag    subscriber_p1    grp_stag     ${client_mac}    ${subscriber_vlan}    session=1
    Tg Control Dhcp Server    tg1    dhcps_stag    start
    Tg Control Dhcp Client    tg1    grp_stag    start
    Tg Save Config Into File    tg1     /tmp/dhcp.xml
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_negociate_time}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    dhcps_stag    grp_stag    rate_pps=${rate_pps}
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    grp_stag    dhcps_stag    rate_pps=${rate_pps}

    log    check traffic can pass without loss
    Tg Start All Traffic     tg1
    sleep    ${send_traffic_time}
    Tg Stop All Traffic    tg1
    Tg Clear Traffic Stats    tg1
    Tg Start All Traffic    tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    tg_verify_traffic_loss_for_stream_is_within    tg1    dhcp_upstream    ${ERPS_max_second_for_switch}
    tg_verify_traffic_loss_for_stream_is_within    tg1    dhcp_downstream    ${ERPS_max_second_for_switch}


    log    STEP:2 disable forwarding interface on master node, then enable it check packet loss
    Tg Clear Traffic Stats    tg1
    sleep    ${send_traffic_time}
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    no_shutdown_port    eutA    ethernet    ${service_model.service_point1.member.interface1}
    wait until keyword succeeds    2 min    5 sec    check_interface_up    eutA    ethernet    ${service_model.service_point1.member.interface1}
    ${expect_max_pkts}    evaluate    ${rate_pps}*${ERPS_max_second_for_switch}
    Tg Stop All Traffic    tg1
    sleep    ${stop_traffic_time}
    TG Verify Traffic Statistics Are Less Than    tg1    dropped_pkts    ${expect_max_pkts}

*** Keywords ***
setup
    [Documentation]
    [Arguments]
    log    Enter setup
    log    Configure an ERPS ring with three nodes

    service_point_prov    service_point_list1
    service_point_prov    service_point_list2
    service_point_prov    service_point_list3
    
    log    check all of the rings are up
    service_point_list_check_status_up    service_point_list1
    service_point_list_check_status_up    service_point_list2
    
    log    Configure data service through erps ring
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444
    :FOR    ${erps_node}    IN    @{service_model.service_point_list2}
    \    log    create dhcp-profile
    \    prov_dhcp_profile    ${service_model.${erps_node}.device}    ${dhcp_profile_name}
    \    log    create service vlan
    \    prov_vlan    ${service_model.${erps_node}.device}    ${service_vlan}    ${dhcp_profile_name}
    prov_vlan_egress    eutA    ${service_vlan}    broadcast-flooding    ENABLED    # Modified by AT-5444

    log    service_point_add_vlan for uplink service
    service_point_add_vlan    service_point_list1    ${service_vlan}
    service_point_add_vlan    service_point_list2    ${service_vlan}
    service_point_add_vlan    service_point_list3    ${service_vlan}

    log    subscriber_point_l2_basic_svc_provision
    subscriber_point_prov    subscriber_point1
    subscriber_point_add_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}    cevlan_action=remove-cevlan


teardown
    [Documentation]
    [Arguments]
    log    Enter teardown

    Tg Control Dhcp Client    tg1    grp_stag    stop
    Tg Control Dhcp Client    tg1    grp_stag    release
    Tg Control Dhcp Server    tg1    dhcps_stag    stop
    Tg Delete Dhcp Client    tg1    dhcpc_stag
    Tg Delete Dhcp Server    tg1    dhcps_stag
    Tg Delete All Traffic    tg1

    log    remove service on ont-port
    subscriber_point_remove_svc    subscriber_point1    ${subscriber_vlan}    ${service_vlan}
    subscriber_point_dprov    subscriber_point1

    log    remove all of the erps interface from service vlan and delete related service profile
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    service_point_remove_vlan    service_point_list2    ${service_vlan}
    service_point_remove_vlan    service_point_list3    ${service_vlan}

    log    deprovision erps ring on each node and delete vlan and l2-dhcp-profile
    service_point_dprov    service_point_list1
    service_point_dprov    service_point_list2
    service_point_dprov    service_point_list3
    :FOR    ${erps_node}    IN    @{service_model.service_point_list1}
    \    delete_config_object    ${service_model.${erps_node}.device}    vlan    ${service_vlan}
    \    delete_config_object    ${service_model.${erps_node}.device}    l2-dhcp-profile    ${dhcp_profile_name}
    delete_config_object    eutB    vlan    ${service_vlan}
    delete_config_object    eutB    l2-dhcp-profile    ${dhcp_profile_name}
