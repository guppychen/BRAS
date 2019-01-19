*** Settings ***
Documentation     Subscriber Side Change-Tag (Original VLAN = Changed-to VLAN) withSingle Tagged Subscriber Traffic
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_Change_Tag_Original_VLAN_Changed_to_VLAN_withSingle_Tagged_Subscriber_Traffic
    [Documentation]    1	Subscriber Side Change-Tag (Original VLAN = Changed-to VLAN) with Single Tagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry. Note: For ENET the Original VLAN MUST be unique to the Changed-to VLAN and therefore this test is not supported on ENET.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-732    @feature=DHCPV4    @globalid=2307076    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-732 setup
    [Teardown]   AXOS_E72_PARENT-TC-732 teardown
    log    STEP:1 Subscriber Side Change-Tag (Original VLAN = Changed-to VLAN) with Single Tagged Subscriber Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry. Note: For ENET the Original VLAN MUST be unique to the Changed-to VLAN and therefore this test is not supported on ENET. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ovlan=${stag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}    ovlan=${Qtag_vlan_2}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    # TG Verify No Traffic Loss For All Streams    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}

*** Keywords ***
AXOS_E72_PARENT-TC-732 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-732 setup
    subscriber_point_add_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}    cevlan_action=remove-cevlan

AXOS_E72_PARENT-TC-732 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-732 teardown
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    subscriber_point_remove_svc    subscriber_point1    ${Qtag_vlan_2}    ${stag_vlan}