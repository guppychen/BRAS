*** Settings ***
Documentation     Subscriber Side Untagged w/ Add-2-Tags with Subscriber Untagged Traffic
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_Subscriber_Side_Untagged_w_Add_2_Tags_with_Subscriber_Untagged_Traffic
    [Documentation]    1	Subscriber Side Untagged w/ Add-2-Tags with Subscriber Untagged Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry.	All Step action expected Results must be correct
    [Tags]       @author=Ronnie_Yi     @TCID=AXOS_E72_PARENT-TC-733    @feature=DHCPV4    @globalid=2307077    @subfeature=DHCP_Snoop_IPv4    @eut=NGPON2-4    @priority=P1
    [Setup]      AXOS_E72_PARENT-TC-733 setup
    [Teardown]   AXOS_E72_PARENT-TC-733 teardown
    log    STEP:1 Subscriber Side Untagged w/ Add-2-Tags with Subscriber Untagged Traffic: Create service with target tag-action on an access interface. The outermost VLAN is enabled for DHCP Relay. Force a subscriber to obtain a dynamic address. Display DHCP Snoop table. -> The subscriber obtains an address. The subscriber address is listed as a DHCP snoop entry. All Step action expected Results must be correct
    log    get dhcp lease and check
    create_dhcp_server    tg1    ${server_name}    service_p1    ${server_mac}     ${server_ip}     ${lease_start}    ${stag_vlan}    ${ctag_vlan}    lease_time=100
    create_dhcp_client    tg1    ${client_name}    subscriber_p1    ${group_name}    ${client_mac}
    Tg Control Dhcp Server    tg1    ${server_name}    start
    Tg Control Dhcp Client    tg1    ${group_name}    start
    Tg Wait Until All Dhcp Session Negotiated    tg1    subscriber_p1    ${lease_wait_time}
    log    show dhcp leases, 1
    check_l3_hosts    eutA    1    ${stag_vlan}    ${service_model.subscriber_point1.name}    ivlan=${ctag_vlan}
    create_bound_traffic_udp    tg1    dhcp_upstream    subscriber_p1    ${server_name}    ${group_name}    10
    create_bound_traffic_udp    tg1    dhcp_downstream    service_p1    ${group_name}    ${server_name}    10
    Tg Start All Traffic     tg1
    sleep    ${traffic_run_time}
    Tg Stop All Traffic    tg1
    TG Verify Traffic Loss Rate For All Streams Is Within    tg1    ${traffic_loss_rate}



*** Keywords ***
AXOS_E72_PARENT-TC-733 setup
    [Documentation]    case setup
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-733 setup
    subscriber_point_add_svc    subscriber_point1    untagged    ${stag_vlan}    add-cevlan-tag    ${ctag_vlan}

AXOS_E72_PARENT-TC-733 teardown
    [Documentation]    case teardown
    [Arguments]
    log    Enter AXOS_E72_PARENT-TC-733 teardown
    log    stop STC
    run keyword and ignore error    Tg Stop All Traffic    tg1
    run keyword and ignore error    Tg Delete All Traffic    tg1
    run keyword and ignore error    Tg Control Dhcp Client    tg1    ${group_name}    stop
    run keyword and ignore error    Tg Control Dhcp Server    tg1    ${server_name}    stop
    run keyword and ignore error    Tg Delete Dhcp Client    tg1    ${client_name}
    run keyword and ignore error    Tg Delete Dhcp Server    tg1    ${server_name}
    log    deprovision svc
    subscriber_point_remove_svc    subscriber_point1    untagged    ${stag_vlan}    ${ctag_vlan}