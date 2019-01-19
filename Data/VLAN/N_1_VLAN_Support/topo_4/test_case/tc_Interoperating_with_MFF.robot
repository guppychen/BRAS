*** Settings ***
Resource          ./base.robot

*** Variables ***

*** Test Cases ***
tc_Interoperating_with_MFF
    [Documentation]    1	connect eth-port1 to a DHCP Server
    ...    2	create a class-map to match untagged in flow 1
    ...    3	create a policy-map to bind the class-map
    ...    4	add eth-port1 to s-tag=100 with transport-service-profile
    ...    5	apply the s-tag and policy-map to the port of ont1 and ont2
    ...    6	Enable DHCP Snooping in VLAN 100
    ...    7	Enable MFF in VLAN 100
    ...    8	Start DHCP process on Client1 and Client2	both Clients get IP addresses successfully
    ...    9	show DHCP leases and MAC table on E7-2
    [Tags]    @author=AnneLI    @globalid=2298772    @tcid=AXOS_E72_PARENT-TC-662     @eut=NGPON2-4    @priority=P2
    [Setup]    setup
    log    step6: Enable DHCP Snooping in VLAN ${service_vlan}
    prov_dhcp_profile    eutA    ${dhcp_profile_name}
    prov_vlan    eutA    ${service_vlan}    ${dhcp_profile_name}
    log    step7: Enable MFF in VLAN ${service_vlan}
    prov_vlan    eutA    ${service_vlan}    mff=enabled
    log    step8: Start DHCP process on Client1 and Client2 both Clients get IP addresses successfully
    create_dhcp_client    tg1    dhcpc_utag_1    p2    grp_utag_1    ${client_mac1}
    create_dhcp_client    tg1    dhcpc_utag_2    p3    grp_utag_2    ${client_mac2}
    log    clear interface counters before start traffic
    clear_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    clear_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}
    Tg Control Dhcp Server    tg1    dhcps_stag    start
    Tg Control Dhcp Client    tg1    grp_utag_1    start
    Tg Control Dhcp Client    tg1    grp_utag_2    start
    log    send traffic,wait ${send_traffic_time}s
    sleep    ${send_traffic_time}
    log    show interface counters after stop traffic
    show_interface_counters    eutA    ${interface_type1}    ${service_model.service_point1.member.interface1}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point1.name}
    show_interface_counters    eutA    ${interface_type2}    ${service_model.subscriber_point2.name}

    tg save config into file   tg1   /tmp/vlanmff.xml

    Tg Wait Until All Dhcp Session Negotiated    tg1    p2    ${lease_negociate_time}
    Tg Wait Until All Dhcp Session Negotiated    tg1    p3    ${lease_negociate_time}
    log    step9: show DHCP leases and MAC table on E7-2
    check_l3_hosts    eutA    2    ${service_vlan}
    check_bridge_table    eutA    ${client_mac1}    ${service_model.subscriber_point1.name}
    check_bridge_table    eutA    ${client_mac2}    ${service_model.subscriber_point2.name}
    [Teardown]    teardown
*** Keywords ***
setup
     [Documentation]    setup
     clear_bridge_table    eutA
     log     step1: connect eth-port1 to a DHCP Server
     create_dhcp_server    tg1    dhcps_stag    p1    ${server_mac}    ${server_ip}    ${pool_ip_start}    ${service_vlan}    lease_time=100    router_list=${server_ip}
     log     step4: add eth-port1 and eth-port2 to s-tag with transport-service-profile
     prov_vlan    eutA    ${service_vlan}
     service_point_add_vlan    service_point_list1    ${service_vlan}
     log     step2: create a class-map to match untagged in flow 1
     log     step3: create a policy-map to bind the class-map
     log     step5: apply the s-tag and policy-map to the port of ont1 and ont2
     subscriber_point_add_svc    subscriber_point1    untagged    ${service_vlan}     cfg_prefix=auto1
     subscriber_point_add_svc    subscriber_point2    untagged    ${service_vlan}     cfg_prefix=auto2
     CLI    eutA    show running-config


teardown
    [Documentation]    teardown
    log    teardown
    Tg Control Dhcp Server    tg1    dhcps_stag     stop
    Tg Control Dhcp Client    tg1    grp_utag_1       stop
    Tg Control Dhcp Client    tg1    grp_utag_2       stop
    Tg Delete Dhcp Server    tg1     dhcps_stag
    Tg Delete Dhcp Client    tg1    dhcpc_utag_1
    Tg Delete Dhcp Client    tg1    dhcpc_utag_2
    log    remove eth-svc from subscriber_point
    subscriber_point_remove_svc    subscriber_point1    untagged    ${service_vlan}     cfg_prefix=auto1
    subscriber_point_remove_svc    subscriber_point2    untagged    ${service_vlan}     cfg_prefix=auto2
    log    service_point remove_svc and deprovision
    dprov_interface_ethernet     eutA    ${service_model.service_point1.member.interface1}    ethertype
    service_point_remove_vlan    service_point_list1    ${service_vlan}
    dprov_vlan    eutA    mff
    log    delete vlan
    delete_config_object    eutA    vlan    ${service_vlan}
    log    wait ${ont_delte_configure_time} to delte ont configure
    sleep    ${ont_delte_configure_time}
    CLI    eutA    show running-config




